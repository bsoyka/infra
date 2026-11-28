# Ansible

[Ansible](https://docs.ansible.com) configuration for my always-on machines. Terraform in the
other directories manages cloud and network services; this directory manages what's installed and
configured *on* the machines themselves. Right now that's just `groundstation`, the Raspberry Pi
that runs Home Assistant.

## Layout

| Path | Contents |
| --- | --- |
| `ansible.cfg` | Inventory and roles paths, `become` on by default |
| `requirements.yml` | Galaxy collections (`community.general`, `hifis.toolkit`) |
| `site.yml` | Entry point; imports everything in `playbooks/` |
| `playbooks/servers.yml` | Applies the `common` role to the `servers` group |
| `inventory/hosts.yml` | Hosts and groups (`servers`, `home_assistant`, `print_server`) |
| `inventory/host_vars/` | Per-host connection settings |
| `roles/common/` | Timezone, base packages, and unattended upgrades (with read-only checks in `tasks/verify.yml`) |
| `pyproject.toml`, `uv.lock` | Pinned Ansible version, managed with [uv](https://docs.astral.sh/uv) |

## What Ansible doesn't manage

- **The tailnet itself.** Tags, ACLs, and device settings live in [`../tailscale`](../tailscale).
  Hosts are reached by their MagicDNS names, so the control machine must be on the tailnet.
- **Home Assistant's configuration** (`~/ha-config` on `groundstation`). It's full of secrets and
  state that Home Assistant rewrites itself; its own backups cover it.

## Prerequisites

- [uv](https://docs.astral.sh/uv), then `uv sync` in this directory
- Galaxy collections: `uv run ansible-galaxy collection install -r requirements.yml`
- SSH access to each host as `bsoyka` over Tailscale, with the host key already in `known_hosts`

## Usage

```sh
cd ansible
uv run ansible-playbook site.yml --check --diff
uv run ansible-playbook site.yml
```

There is no CI pipeline -- runs happen locally.

## Notes

- `roles/common` wraps `hifis.toolkit.unattended_upgrades` with `import_role` and passes it the
  `common_unattended_*` variables. Setting the update sources *replaces* the role's defaults, so
  Debian's security sources are listed explicitly alongside Raspberry Pi and Tailscale.
- Unattended upgrades never reboot on their own. Package lists refresh around 02:30 and upgrades
  install around 03:00 (Central), clear of Home Assistant's nightly backup.
- The checks in `roles/common/tasks/verify.yml` are skipped in `--check` mode, since nothing has
  been written yet on a first run.
