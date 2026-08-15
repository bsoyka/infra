# lunarleisure.com: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  lunarleisure_com_settings = {
    "lunarleisure.com/always_online"            = { zone = "lunarleisure.com", setting_id = "always_online", value = "off" }
    "lunarleisure.com/always_use_https"         = { zone = "lunarleisure.com", setting_id = "always_use_https", value = "on" }
    "lunarleisure.com/automatic_https_rewrites" = { zone = "lunarleisure.com", setting_id = "automatic_https_rewrites", value = "on" }
    "lunarleisure.com/brotli"                   = { zone = "lunarleisure.com", setting_id = "brotli", value = "off" }
    "lunarleisure.com/browser_check"            = { zone = "lunarleisure.com", setting_id = "browser_check", value = "off" }
    "lunarleisure.com/challenge_ttl"            = { zone = "lunarleisure.com", setting_id = "challenge_ttl", value = 31536000 }
    "lunarleisure.com/early_hints"              = { zone = "lunarleisure.com", setting_id = "early_hints", value = "off" }
    "lunarleisure.com/hotlink_protection"       = { zone = "lunarleisure.com", setting_id = "hotlink_protection", value = "off" }
    "lunarleisure.com/min_tls_version"          = { zone = "lunarleisure.com", setting_id = "min_tls_version", value = "1.0" }
    "lunarleisure.com/opportunistic_encryption" = { zone = "lunarleisure.com", setting_id = "opportunistic_encryption", value = "on" }
    "lunarleisure.com/rocket_loader"            = { zone = "lunarleisure.com", setting_id = "rocket_loader", value = "off" }
    "lunarleisure.com/security_level"           = { zone = "lunarleisure.com", setting_id = "security_level", value = "essentially_off" }
    "lunarleisure.com/ssl"                      = { zone = "lunarleisure.com", setting_id = "ssl", value = "flexible" }
    "lunarleisure.com/tls_1_3"                  = { zone = "lunarleisure.com", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "lunarleisure_com_apex_cname" {
  zone_id = local.zone_ids["lunarleisure.com"]
  name    = "lunarleisure.com"
  type    = "CNAME"
  content = "lunarleisure.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "lunarleisure_com_apex_mx" {
  for_each = { "route1.mx.cloudflare.net" = 29, "route2.mx.cloudflare.net" = 76, "route3.mx.cloudflare.net" = 14 }

  zone_id  = local.zone_ids["lunarleisure.com"]
  name     = "lunarleisure.com"
  type     = "MX"
  content  = each.key
  priority = each.value
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "lunarleisure_com_apex_txt" {
  zone_id = local.zone_ids["lunarleisure.com"]
  name    = "lunarleisure.com"
  type    = "TXT"
  content = "v=spf1 include:_spf.mx.cloudflare.net ~all"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "lunarleisure_com_cf2024_1_domainkey_txt" {
  zone_id = local.zone_ids["lunarleisure.com"]
  name    = "cf2024-1._domainkey.lunarleisure.com"
  type    = "TXT"
  content = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "lunarleisure_com_dev_cname" {
  zone_id = local.zone_ids["lunarleisure.com"]
  name    = "dev.lunarleisure.com"
  type    = "CNAME"
  content = "lunarleisure-dev.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "lunarleisure_com_www_cname" {
  zone_id = local.zone_ids["lunarleisure.com"]
  name    = "www.lunarleisure.com"
  type    = "CNAME"
  content = "lunarleisure.pages.dev"
  ttl     = 1
  proxied = true
}
