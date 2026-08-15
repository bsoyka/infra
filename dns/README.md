# DNS configuration

My DNS records are hosted with [Cloudflare](https://www.cloudflare.com/application-services/products/dns/).
This directory is a [Terraform](https://developer.hashicorp.com/terraform) root module that manages the zones, their DNS records, their redirect rules, and a curated set of zone settings.

## Layout

| File | Contents |
| --- | --- |
| `versions.tf` | Terraform and provider version constraints |
| `backend.tf` | S3 remote state (`bsoyka-tfstate/infra-dns.tfstate`) |
| `providers.tf` | Cloudflare provider |
| `locals.tf` | Account ID, the zone ID map, and the merged zone-settings map |
| `zones.tf` | `cloudflare_zone` for each zone |
| `zone-settings.tf` | The `cloudflare_zone_setting` resource that applies `local.zone_settings` |
| `zones-*.tf` | One file per zone: its DNS records, its slice of zone settings (as a `locals` block), and its redirect ruleset, if any |

Everything specific to a single zone lives in that zone's `zones-*.tf` file. The other files are
shared mechanism — they don't hold per-zone data themselves.

## Prerequisites

- `terraform`, pinned in the repo's `mise.toml` — run `mise install`
- AWS credentials with read/write on `s3://bsoyka-tfstate` (for state)
- A Cloudflare API token exported as `CLOUDFLARE_API_TOKEN`

The token needs these permissions on all zones in the account:

- Zone → Zone → Edit
- Zone → DNS → Edit
- Zone → Zone Settings → Edit
- Zone → Dynamic Redirect → Edit
- Zone → Page Rules → Edit

Both credentials are set locally via [direnv](https://direnv.net) in the repo's `.envrc`, which is
gitignored.

## Usage

```sh
cd dns
terraform init
terraform plan
terraform apply
```

There is no CI pipeline yet — plans and applies run locally.

## Notes

- Zones carry `prevent_destroy`. Removing one is deliberate work, not something a plan can do by accident.
- Redirects use [Dynamic Redirects](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/), not Page Rules. A handful of zones still have old Page Rules that duplicate a
  redirect rule; they're harmless (the redirect rule matches first) but the Cloudflare API
  [refuses to let account-owned tokens delete Page Rules](https://developers.cloudflare.com/fundamentals/api/reference/limits/) (`1011`), so removing them has to be done by hand in the dashboard.
- `tags` and `settings` are omitted from records that don't need them — both are
  `optional, computed` in the provider schema, so leaving them out is equivalent to the empty
  value Cloudflare already returns.
- Proxied records must use `ttl = 1`, which Cloudflare treats as "automatic." `ttl` is a required
  field, so this can't be omitted even where it's the default.
- Some zones' apexes carry an `AAAA "100::"` record that Cloudflare manages automatically as a
  side effect of a Workers Custom Domain binding. Those aren't modeled here — see
  [`workers/`](../workers) instead. Modeling one as a plain `cloudflare_dns_record` doesn't work:
  the record is read-only, and any attempt to change or delete it fails with API error `1043`.
