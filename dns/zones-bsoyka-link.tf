# bsoyka.link: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  bsoyka_link_settings = {
    "bsoyka.link/always_online"            = { zone = "bsoyka.link", setting_id = "always_online", value = "off" }
    "bsoyka.link/always_use_https"         = { zone = "bsoyka.link", setting_id = "always_use_https", value = "off" }
    "bsoyka.link/automatic_https_rewrites" = { zone = "bsoyka.link", setting_id = "automatic_https_rewrites", value = "on" }
    "bsoyka.link/brotli"                   = { zone = "bsoyka.link", setting_id = "brotli", value = "on" }
    "bsoyka.link/browser_check"            = { zone = "bsoyka.link", setting_id = "browser_check", value = "on" }
    "bsoyka.link/challenge_ttl"            = { zone = "bsoyka.link", setting_id = "challenge_ttl", value = 1800 }
    "bsoyka.link/early_hints"              = { zone = "bsoyka.link", setting_id = "early_hints", value = "off" }
    "bsoyka.link/hotlink_protection"       = { zone = "bsoyka.link", setting_id = "hotlink_protection", value = "off" }
    "bsoyka.link/min_tls_version"          = { zone = "bsoyka.link", setting_id = "min_tls_version", value = "1.0" }
    "bsoyka.link/opportunistic_encryption" = { zone = "bsoyka.link", setting_id = "opportunistic_encryption", value = "on" }
    "bsoyka.link/rocket_loader"            = { zone = "bsoyka.link", setting_id = "rocket_loader", value = "off" }
    "bsoyka.link/security_level"           = { zone = "bsoyka.link", setting_id = "security_level", value = "medium" }
    "bsoyka.link/ssl"                      = { zone = "bsoyka.link", setting_id = "ssl", value = "full" }
    "bsoyka.link/tls_1_3"                  = { zone = "bsoyka.link", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "bsoyka_link_apex_a" {
  zone_id = local.zone_ids["bsoyka.link"]
  name    = "bsoyka.link"
  type    = "A"
  content = "76.76.21.21"
  ttl     = 1
  proxied = false
  comment = "dub.co"
}

resource "cloudflare_dns_record" "bsoyka_link_apex_txt" {
  for_each = toset(["google-site-verification=NGEVnPDMIZA1Nkw1hMIp0i78s6vy1araVCMmClhkAsw"])

  zone_id = local.zone_ids["bsoyka.link"]
  name    = "bsoyka.link"
  type    = "TXT"
  content = each.key
  ttl     = 1
  proxied = false
}
