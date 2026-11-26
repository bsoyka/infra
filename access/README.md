# Access (bensoyka.net)

[Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/applications/) in front of
everything on `bensoyka.net`, the domain for tools that are just for me. Public-facing things stay
on `bensoyka.com`.

## How it behaves

| Application | Hostnames | Who gets in |
| --- | --- | --- |
| `bensoyka.net landing page (public)` | `bensoyka.net` | Everyone (no login): just a page pointing to bensoyka.com |
| `bensoyka.net (catch-all)` | `*.bensoyka.net` | Ben |
| `Upload (share.bensoyka.com)` | `upload.bensoyka.net` | Ben, service tokens (the Worker only accepts the `share` CLI's), and anyone in `upload_guests` |

- Access uses the most specific application for a hostname, so a new tool on a `bensoyka.net`
  subdomain is mine-only from the moment it has DNS. Give it its own application only when it needs different
  rules.
- Sign-ins last 30 days per device (`session_duration` in `locals.tf`).
- The login page offers every identity provider on the account: email code, Google, GitHub,
  and Cloudflare (all added by hand; see below). Whichever one is used, the address
  it reports still has to be in the `Ben` group (or a guest list) to get in.

### Who "Ben" is

The `Ben` group is every email address on my current PGP key. On each plan,
`scripts/pgp-emails.sh` fetches `https://keys.bensoyka.com/pgp.asc`, refuses it unless its
fingerprint matches the one pinned in `locals.tf`, and returns the addresses of user IDs that
aren't revoked or expired.

- **Adding an address:** add the UID to the key, publish it (bsoyka/keys), then `terraform apply`
  here.
- **Removing one:** revoke the UID, publish, and apply. It drops out of the group.
- **New key:** update `pgp_key.fingerprint` in `locals.tf` in the same change. Until you do, the plan
  fails instead of trusting the new key.

The group only changes when this module is applied, not live.

## Layout

| File | Contents |
| --- | --- |
| `versions.tf` | Terraform and provider version constraints |
| `backend.tf` | S3 remote state (`bsoyka-tfstate/infra-access.tfstate`) |
| `providers.tf` | Cloudflare provider |
| `locals.tf` | Account ID, session length, pinned PGP key, guest list |
| `identity.tf` | Notes on the login methods (all managed by hand) |
| `groups.tf` | `Ben` group (from the PGP key) and the reusable policies |
| `apps.tf` | The catch-all and `upload.bensoyka.net` applications |
| `outputs.tf` | The group's addresses and the upload app's audience tag |
| `scripts/pgp-emails.sh` | External data source that reads emails off the PGP key |

## Prerequisites

Same as [`dns/`](../dns), plus:

- `gpg`, `curl`, and `jq` on the machine running Terraform (for `scripts/pgp-emails.sh`).
- A Zero Trust organization on the account (the free plan is fine), with a team domain picked
  in Zero Trust → Settings.
- `CLOUDFLARE_API_TOKEN` additionally needs, at the account level:
  - Access: Apps and Policies → Edit
  - Access: Organizations, Identity Providers, and Groups → Edit

## Things done by hand

These hold secrets, so they're kept out of Terraform state.

**Email code.** Zero Trust → Integrations → Identity providers → Add new → One-time PIN (it was
already there on this account).

**Google and GitHub sign-in.** Add each under Zero Trust → Settings → Authentication → Login
methods, following Cloudflare's guides
([Google](https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/google/),
[GitHub](https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/github/)). Both
Google accounts work through the one Google provider. GitHub signs in with the account's primary
email, so that address has to be on the PGP key.

**Cloudflare sign-in.** Zero Trust → Integrations → Identity providers → Add new → Cloudflare.
My Cloudflare account's email has to be on the PGP key for it to get me in.

**Service tokens.** Create under Zero Trust → Access controls → Service credentials → Service
Tokens, with the longest duration. The secret goes only to the client that uses it (for the CLI:
`share --setup`, which saves it in the macOS Keychain). Access lets any valid token on the
account through to apps that allow service tokens, so the **client ID** (not secret) also goes in
the app's own allowlist: for share-upload, `ALLOWED_SERVICE_TOKENS` in its `wrangler.toml`.

## First deploy

No IDs to copy in first; just:

```sh
cd access
terraform init
terraform apply
terraform output upload_aud   # goes in share-upload's wrangler.toml
```
