# mountainspalette.com: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  mountainspalette_com_settings = {
    "mountainspalette.com/always_online"            = { zone = "mountainspalette.com", setting_id = "always_online", value = "off" }
    "mountainspalette.com/always_use_https"         = { zone = "mountainspalette.com", setting_id = "always_use_https", value = "off" }
    "mountainspalette.com/automatic_https_rewrites" = { zone = "mountainspalette.com", setting_id = "automatic_https_rewrites", value = "on" }
    "mountainspalette.com/brotli"                   = { zone = "mountainspalette.com", setting_id = "brotli", value = "on" }
    "mountainspalette.com/browser_check"            = { zone = "mountainspalette.com", setting_id = "browser_check", value = "on" }
    "mountainspalette.com/challenge_ttl"            = { zone = "mountainspalette.com", setting_id = "challenge_ttl", value = 1800 }
    "mountainspalette.com/early_hints"              = { zone = "mountainspalette.com", setting_id = "early_hints", value = "off" }
    "mountainspalette.com/hotlink_protection"       = { zone = "mountainspalette.com", setting_id = "hotlink_protection", value = "off" }
    "mountainspalette.com/min_tls_version"          = { zone = "mountainspalette.com", setting_id = "min_tls_version", value = "1.0" }
    "mountainspalette.com/opportunistic_encryption" = { zone = "mountainspalette.com", setting_id = "opportunistic_encryption", value = "on" }
    "mountainspalette.com/rocket_loader"            = { zone = "mountainspalette.com", setting_id = "rocket_loader", value = "off" }
    "mountainspalette.com/security_level"           = { zone = "mountainspalette.com", setting_id = "security_level", value = "medium" }
    "mountainspalette.com/ssl"                      = { zone = "mountainspalette.com", setting_id = "ssl", value = "flexible" }
    "mountainspalette.com/tls_1_3"                  = { zone = "mountainspalette.com", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "mountainspalette_com_apex_cname" {
  zone_id = local.zone_ids["mountainspalette.com"]
  name    = "mountainspalette.com"
  type    = "CNAME"
  content = "themountainspalette.etsy.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "mountainspalette_com_apex_txt" {
  zone_id = local.zone_ids["mountainspalette.com"]
  name    = "mountainspalette.com"
  type    = "TXT"
  content = "facebook-domain-verification=9nbdlha3abztb8yao15cudk9woscd0"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "mountainspalette_com_www_cname" {
  zone_id = local.zone_ids["mountainspalette.com"]
  name    = "www.mountainspalette.com"
  type    = "CNAME"
  content = "themountainspalette.etsy.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "mountainspalette_com_redirects" {
  zone_id = local.zone_ids["mountainspalette.com"]
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  # The two original Page Rules (apex and www) had identical targets, so they
  # collapse into a single rule.
  rules = [
    {
      ref         = "all_to_etsy_shop"
      description = "mountainspalette.com/* and www -> themountainspalette.etsy.com/*"
      expression  = "(http.host in {\"mountainspalette.com\" \"www.mountainspalette.com\"})"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://themountainspalette.etsy.com\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
