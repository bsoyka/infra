# website: https://github.com/bsoyka/website
#
# Served on bensoyka.com and www.bensoyka.com. bsoyka.me and www.bsoyka.me
# redirect here with a Cloudflare redirect rule (dns/zones-bsoyka-me.tf), not
# through the Worker: Workers serve static assets before any code runs, so a
# redirect in the site's middleware never fired for most pages.

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
