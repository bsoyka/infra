# Share (share.bensoyka.com)

Temporary file sharing for screenshots (Shottr) and large email attachments
(Thunderbird FileLink). Files land in a private S3 bucket, are served through
CloudFront on `share.bensoyka.com`, and expire on their own.

Long-lived public files (CV, profile photos, ...) stay on `assets.bensoyka.com`.
The two are kept apart on purpose: different retention, different trust (these
are uploads, not curated files), and the assets deploy shouldn't be able to wipe
or be wiped by uploads.

## Layout

| File | Contents |
| --- | --- |
| `versions.tf` | Terraform and provider version constraints |
| `backend.tf` | S3 remote state (`bsoyka-tfstate/infra-share.tfstate`) |
| `providers.tf` | AWS provider (us-east-1, default tags) |
| `locals.tf` | Domain, bucket name, and the per-client prefix map (path + retention) |
| `bucket.tf` | Private bucket, ownership/public-access settings, lifecycle, CloudFront-only read policy |
| `cdn.tf` | ACM certificate, CloudFront distribution, response-header policies |
| `uploaders.tf` | One IAM user per client, write-only to its own prefix |
| `outputs.tf` | CloudFront domain and ACM validation record for `dns/` |

## How it behaves

| Prefix | Client | Expires | In the browser |
| --- | --- | --- | --- |
| `shottr/` | Shottr | 90 days | Rendered inline, under `Content-Security-Policy: sandbox` |
| `mail/` | Thunderbird FileLink | 60 days | Always downloaded (`Content-Disposition: attachment`) |

- Nobody can list the bucket; a link only works if you have the exact object name.
- Every response carries `nosniff`, `no-referrer`, HSTS, and `X-Robots-Tag: noindex, nofollow`.
- The uploaders can write (and, for `mail/`, delete) but never read or list.

## Prerequisites

Same as [`dns/`](../dns): `terraform` via `mise install` and AWS credentials for
`s3://bsoyka-tfstate`. Those credentials also need to manage S3, CloudFront,
ACM, and IAM users/policies.

## First deploy

The certificate has to validate before CloudFront will accept it, and the
validation record lives in `dns/`, so the first deploy goes back and forth once:

1. Create just the certificate:

   ```sh
   cd share
   terraform init
   terraform apply -target=aws_acm_certificate.share
   terraform output acm_validation_records
   ```

2. Add that CNAME to `dns/zones-bensoyka-com.tf` (next to the keys/assets ones,
   `proxied = false`) and apply `dns/`.
3. Apply everything here. `aws_acm_certificate_validation` waits for ACM, then
   CloudFront is created (that part takes a few minutes):

   ```sh
   terraform apply
   terraform output cloudfront_domain
   ```

4. Add `share.bensoyka.com` as a CNAME to that domain in `dns/zones-bensoyka-com.tf`
   (`proxied = false`) and apply `dns/`.

## Access keys

Keys are created by hand so the secret never touches Terraform state:

```sh
aws iam create-access-key --user-name bsoyka-share-shottr
aws iam create-access-key --user-name bsoyka-share-mail
```

Put each into 1Password right away. To rotate: create a second key, swap it into
the client, then `aws iam delete-access-key --user-name bsoyka-share-<client> --access-key-id <old>`.

## Client setup

**Shottr** (Settings → Uploading): Service "Amazon (AWS)", region `us-east-1`,
bucket `bsoyka-share`, Public Bucket URL `https://share.bensoyka.com`, keys
from `bsoyka-share-shottr`. Uploads must go under `shottr/`; the policy denies anything
else, which is a useful check that the prefix setting took.

**Thunderbird** (S3 FileLink Provider add-on): same bucket and region, keys from
`bsoyka-share-mail`, path prefix `mail/`, link base `https://share.bensoyka.com/`.

## Known risks / things to check on first use

- **Object ACLs:** the bucket has ACLs disabled (`BucketOwnerEnforced`). If a
  client sends `x-amz-acl: public-read` with its uploads, S3 rejects them with
  `AccessControlListNotSupported`. Turn that option off in the client if it has one;
  public access comes from CloudFront, not ACLs.
- **Shottr's prefix support:** Shottr's docs don't mention a path setting. If it
  can only write to the bucket root, change the `shottr` prefix in `locals.tf`
  to match its filenames (e.g. `SCR-`) instead of a folder.
- **Guessable names:** Shottr's default names are a date plus a short suffix. If
  it supports a filename template, add more randomness; the bucket can't be
  listed, but short names can be brute-forced.
- **Shottr's "Test Connection"** may try an operation the write-only policy
  doesn't allow. If the test fails but a real upload works, that's fine.
