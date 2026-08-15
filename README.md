# bsoyka/infra

This project contains [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC) for my personal projects.
Not every piece of infrastructure I use is listed/controlled here, but I aim to [slowly migrate](https://github.com/users/bsoyka/projects/3) more configurations to this repository over time.

Everything here is managed with [Terraform](https://developer.hashicorp.com/terraform), with state in S3.
Tool versions are pinned in `mise.toml`.

| Directory | Contents |
| --- | --- |
| [`dns/`](dns) | Cloudflare zones, DNS records, redirects, and zone settings |
| [`workers/`](workers) | Cloudflare Workers Custom Domains and KV namespaces |
| [`tailscale/`](tailscale) | Tailscale ACL policy, DNS, tailnet settings, and device configuration |
