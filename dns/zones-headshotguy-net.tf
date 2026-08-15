# headshotguy.net: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  headshotguy_net_settings = {
    "headshotguy.net/always_online"            = { zone = "headshotguy.net", setting_id = "always_online", value = "off" }
    "headshotguy.net/always_use_https"         = { zone = "headshotguy.net", setting_id = "always_use_https", value = "off" }
    "headshotguy.net/automatic_https_rewrites" = { zone = "headshotguy.net", setting_id = "automatic_https_rewrites", value = "on" }
    "headshotguy.net/brotli"                   = { zone = "headshotguy.net", setting_id = "brotli", value = "on" }
    "headshotguy.net/browser_check"            = { zone = "headshotguy.net", setting_id = "browser_check", value = "on" }
    "headshotguy.net/challenge_ttl"            = { zone = "headshotguy.net", setting_id = "challenge_ttl", value = 1800 }
    "headshotguy.net/early_hints"              = { zone = "headshotguy.net", setting_id = "early_hints", value = "off" }
    "headshotguy.net/hotlink_protection"       = { zone = "headshotguy.net", setting_id = "hotlink_protection", value = "off" }
    "headshotguy.net/min_tls_version"          = { zone = "headshotguy.net", setting_id = "min_tls_version", value = "1.0" }
    "headshotguy.net/opportunistic_encryption" = { zone = "headshotguy.net", setting_id = "opportunistic_encryption", value = "on" }
    "headshotguy.net/rocket_loader"            = { zone = "headshotguy.net", setting_id = "rocket_loader", value = "off" }
    "headshotguy.net/security_level"           = { zone = "headshotguy.net", setting_id = "security_level", value = "medium" }
    "headshotguy.net/ssl"                      = { zone = "headshotguy.net", setting_id = "ssl", value = "flexible" }
    "headshotguy.net/tls_1_3"                  = { zone = "headshotguy.net", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "headshotguy_net_apex_cname" {
  zone_id = local.zone_ids["headshotguy.net"]
  name    = "headshotguy.net"
  type    = "CNAME"
  content = "bsoyka.pixieset.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "headshotguy_net_www_cname" {
  zone_id = local.zone_ids["headshotguy.net"]
  name    = "www.headshotguy.net"
  type    = "CNAME"
  content = "bsoyka.pixieset.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "headshotguy_net_redirects" {
  zone_id = local.zone_ids["headshotguy.net"]
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  # Catch-all: the whole zone points at the Pixieset booking page.
  rules = [
    {
      ref         = "77c4aca1197d4d12b9086ff4cd7a8fea"
      description = "Send to booking"
      expression  = "true"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = false
          target_url = {
            value = "https://bsoyka.pixieset.com/booking/"
          }
        }
      }
    },
  ]
}
