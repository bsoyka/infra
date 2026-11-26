# Share (share.bensoyka.com)

Temporary file sharing: screenshots (Shottr), large email attachments
(Thunderbird FileLink), and files I upload by hand (the upload page at
`upload.bensoyka.net` and the `share` CLI, both in bsoyka/share-upload). Files
land in a private S3 bucket, are served through CloudFront on
`share.bensoyka.com`, and expire on their own.

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
| `locals.tf` | Domain, bucket name, prefixes (path, retention, inline/download), uploaders, upload page origins |
| `bucket.tf` | Private bucket, ownership/public-access settings, lifecycle, CORS for the upload page, CloudFront-only read policy |
| `cdn.tf` | ACM certificate, CloudFront distribution, response-header policies |
| `uploaders.tf` | One IAM user per client, write-only to its own prefixes |
| `outputs.tf` | CloudFront domain and ACM validation record for `dns/` |

## How it behaves

| Prefix | Clients | Expires | In the browser |
| --- | --- | --- | --- |
| `screenshot/` | Shottr | 90 days | Rendered inline, under `Content-Security-Policy: sandbox` |
| `file/` | Thunderbird FileLink, share-upload | 60 days | Always downloaded (`Content-Disposition: attachment`) |

| IAM user | Can write to | Can delete |
| --- | --- | --- |
| `bsoyka-share-shottr` | `screenshot/` | No |
| `bsoyka-share-mail` | `file/` | Yes |
| `bsoyka-share-upload` | `file/` (directly, or through URLs it presigns) | Yes, and clears CloudFront's cache for what it deletes |

- CloudFront caches files for up to a day, so deleting an object alone doesn't kill its link
  right away. share-upload clears the cache for each upload it deletes; anything deleted
  another way (console, FileLink) can keep downloading until its cached copy expires.
- Nobody can list the bucket; a link only works if you have the exact object name.
- Every response carries `nosniff`, `no-referrer`, HSTS, and `X-Robots-Tag: noindex, nofollow`.
- The uploaders can write (and delete, where noted) but never read or list.
- The bucket's CORS rule allows `PUT` from `https://upload.bensoyka.net` only, so the upload page
  can send files straight to S3 with a presigned URL. CORS grants nothing by itself: every
  request still needs a valid signature.

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
aws iam create-access-key --user-name bsoyka-share-upload
```

Paste each straight into its client (the upload key becomes two `wrangler secret`s; see
share-upload's README). If one is lost, make a new one rather than recovering it. To rotate: create a second key, swap it into
the client, then `aws iam delete-access-key --user-name bsoyka-share-<client> --access-key-id <old>`.

## Client setup

**Shottr** (Settings → Uploading): Service "Amazon (AWS)", region `us-east-1`,
bucket `bsoyka-share`, Public Bucket URL `https://share.bensoyka.com`, keys
from `bsoyka-share-shottr`. Uploads must go under `screenshot/`; the policy denies anything
else, which is a useful check that the prefix setting took.

**Thunderbird** (bsoyka/share-filelink): keys from `bsoyka-share-mail`, path prefix `file/`.
Version 1.1.0 and later move an existing account from the old `mail/` prefix to `file/` on
their own.

**share-upload** (bsoyka/share-upload): keys from `bsoyka-share-upload`, stored as Worker
secrets.

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
