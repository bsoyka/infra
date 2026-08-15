# minnehack-2026: https://github.com/bsoyka/minnehack-2026

resource "cloudflare_workers_custom_domain" "minnehack_2026" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bensoyka.com"]
  hostname   = "minnehack.bensoyka.com"
  service    = "minnehack-2026"
}
