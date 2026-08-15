# Workers infrastructure

My [Cloudflare Workers](https://developers.cloudflare.com/workers/) projects each live in their
own repo and deploy their own code (`wrangler deploy` or equivalent). This directory is a
[Terraform](https://developer.hashicorp.com/terraform) root module that manages the durable cloud
resources those Workers depend on — Custom Domain bindings and KV namespaces — not the scripts
themselves.

## Layout

| File | Contents |
| --- | --- |
| `versions.tf` | Terraform and provider version constraints |
| `backend.tf` | S3 remote state (`bsoyka-tfstate/infra-workers.tfstate`) |
| `providers.tf` | Cloudflare provider |
| `locals.tf` | Account ID and the zone ID map (kept in sync by hand with `dns/locals.tf`) |
| `workers-*.tf` | One file per Worker project: its Custom Domain(s) and KV namespace(s), if any |

## Why not manage the script itself?

The Cloudflare provider's `cloudflare_workers_script` resource needs the built script content —
`content`/`content_file` pointing at a bundle on disk. Managing that here would mean building each
project (Next.js via OpenNext, Astro, ...) before every `terraform apply`, coupling this repo to
every Worker project's own build tooling. Instead:

- **Terraform (here) owns**: the Custom Domain binding and KV namespace as durable objects —
  things that rarely change and are easy to lose track of (see the [`dns/`](../dns) README for
  the DNS-side landmine that motivated this split).
- **Each Worker's own repo owns**: the code, and deploying it via `wrangler deploy` (or
  `opennextjs-cloudflare deploy`) exactly as today.

The two don't conflict. A project's `wrangler.jsonc` still declares the same KV namespace ID and
`routes: [{ pattern: "...", custom_domain: true }]` — those are bindings the *script* needs to
reference at runtime, not a competing definition. `wrangler deploy` attaches to the
already-existing objects Terraform created; it doesn't recreate them.

## Prerequisites

Same as [`dns/`](../dns): `terraform` via `mise install`, AWS credentials for
`s3://bsoyka-tfstate`, and `CLOUDFLARE_API_TOKEN` exported (via the repo's gitignored `.envrc`).
The token additionally needs Workers Scripts, Workers KV Storage, and Workers Routes permissions
at the account level.

## Usage

```sh
cd workers
terraform init
terraform plan
terraform apply
```

There is no CI pipeline yet — plans and applies run locally.
