# bsoyka/infra

This project contains [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC) for my personal projects.
Not every piece of infrastructure I use is listed/controlled here, but I aim to [slowly migrate](https://github.com/users/bsoyka/projects/3) more configurations to this repository over time.

Cloud and network infrastructure is managed with [Terraform](https://developer.hashicorp.com/terraform), with state in S3.
The always-on machines themselves are configured with [Ansible](https://docs.ansible.com).
Terraform's version is pinned in `mise.toml`; Ansible's is pinned in `ansible/uv.lock`.

| Directory | Contents |
| --- | --- |
| [`dns/`](dns) | Cloudflare zones, DNS records, redirects, and zone settings |
| [`workers/`](workers) | Cloudflare Workers Custom Domains and KV namespaces |
| [`tailscale/`](tailscale) | Tailscale ACL policy, DNS, tailnet settings, and device configuration |
| [`share/`](share) | `share.bensoyka.com`: S3 + CloudFront for temporary screenshots and shared files |
| [`access/`](access) | Cloudflare Access for `bensoyka.net`, the domain for my own tools |
| [`ansible/`](ansible) | Ansible for the always-on machines (currently the Home Assistant Pi, `groundstation`) |
