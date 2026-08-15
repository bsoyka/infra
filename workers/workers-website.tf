# website: https://github.com/bsoyka/website
#
# One script served across two zones, four hostnames.

resource "cloudflare_workers_custom_domain" "website_bsoyka_me" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bsoyka.me"]
  hostname   = "bsoyka.me"
  service    = "website"
}

resource "cloudflare_workers_custom_domain" "website_www_bsoyka_me" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bsoyka.me"]
  hostname   = "www.bsoyka.me"
  service    = "website"
}

resource "cloudflare_workers_custom_domain" "website_bensoyka_com" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bensoyka.com"]
  hostname   = "bensoyka.com"
  service    = "website"
}

resource "cloudflare_workers_custom_domain" "website_www_bensoyka_com" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bensoyka.com"]
  hostname   = "www.bensoyka.com"
  service    = "website"
}

resource "cloudflare_workers_kv_namespace" "website_session" {
  account_id = local.account_id
  title      = "website-session"
}
