# howlonghasthehubbeenunderconstruction.com: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  hub_construction_settings = {
    "howlonghasthehubbeenunderconstruction.com/always_online"            = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "always_online", value = "off" }
    "howlonghasthehubbeenunderconstruction.com/always_use_https"         = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "always_use_https", value = "off" }
    "howlonghasthehubbeenunderconstruction.com/automatic_https_rewrites" = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "automatic_https_rewrites", value = "on" }
    "howlonghasthehubbeenunderconstruction.com/brotli"                   = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "brotli", value = "on" }
    "howlonghasthehubbeenunderconstruction.com/browser_check"            = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "browser_check", value = "on" }
    "howlonghasthehubbeenunderconstruction.com/challenge_ttl"            = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "challenge_ttl", value = 1800 }
    "howlonghasthehubbeenunderconstruction.com/early_hints"              = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "early_hints", value = "off" }
    "howlonghasthehubbeenunderconstruction.com/hotlink_protection"       = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "hotlink_protection", value = "off" }
    "howlonghasthehubbeenunderconstruction.com/min_tls_version"          = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "min_tls_version", value = "1.0" }
    "howlonghasthehubbeenunderconstruction.com/opportunistic_encryption" = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "opportunistic_encryption", value = "on" }
    "howlonghasthehubbeenunderconstruction.com/rocket_loader"            = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "rocket_loader", value = "off" }
    "howlonghasthehubbeenunderconstruction.com/security_level"           = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "security_level", value = "medium" }
    "howlonghasthehubbeenunderconstruction.com/ssl"                      = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "ssl", value = "full" }
    "howlonghasthehubbeenunderconstruction.com/tls_1_3"                  = { zone = "howlonghasthehubbeenunderconstruction.com", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "hub_construction_apex_aaaa" {
  zone_id = local.zone_ids["howlonghasthehubbeenunderconstruction.com"]
  name    = "howlonghasthehubbeenunderconstruction.com"
  type    = "AAAA"
  content = "100::"
  ttl     = 1
  proxied = true
}
