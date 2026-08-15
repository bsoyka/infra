# bensoyka.com: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  bensoyka_com_settings = {
    "bensoyka.com/always_online"            = { zone = "bensoyka.com", setting_id = "always_online", value = "off" }
    "bensoyka.com/always_use_https"         = { zone = "bensoyka.com", setting_id = "always_use_https", value = "off" }
    "bensoyka.com/automatic_https_rewrites" = { zone = "bensoyka.com", setting_id = "automatic_https_rewrites", value = "on" }
    "bensoyka.com/brotli"                   = { zone = "bensoyka.com", setting_id = "brotli", value = "on" }
    "bensoyka.com/browser_check"            = { zone = "bensoyka.com", setting_id = "browser_check", value = "on" }
    "bensoyka.com/challenge_ttl"            = { zone = "bensoyka.com", setting_id = "challenge_ttl", value = 1800 }
    "bensoyka.com/early_hints"              = { zone = "bensoyka.com", setting_id = "early_hints", value = "off" }
    "bensoyka.com/hotlink_protection"       = { zone = "bensoyka.com", setting_id = "hotlink_protection", value = "off" }
    "bensoyka.com/min_tls_version"          = { zone = "bensoyka.com", setting_id = "min_tls_version", value = "1.0" }
    "bensoyka.com/opportunistic_encryption" = { zone = "bensoyka.com", setting_id = "opportunistic_encryption", value = "on" }
    "bensoyka.com/rocket_loader"            = { zone = "bensoyka.com", setting_id = "rocket_loader", value = "off" }
    "bensoyka.com/security_level"           = { zone = "bensoyka.com", setting_id = "security_level", value = "medium" }
    "bensoyka.com/ssl"                      = { zone = "bensoyka.com", setting_id = "ssl", value = "full" }
    "bensoyka.com/tls_1_3"                  = { zone = "bensoyka.com", setting_id = "tls_1_3", value = "on" }
  }
}

# ------------ APEX RECORDS ------------
#
# bensoyka.com and www.bensoyka.com also carry an "100::" AAAA placeholder
# that Cloudflare manages automatically as a side effect of the `website`
# Worker's Custom Domain binding. That's not a DNS record to manage here --
# see workers/workers-website.tf.

resource "cloudflare_dns_record" "bensoyka_com_apex_txt" {
  for_each = toset(["\"apple-domain=CLN3hTkjJIb9wrXk\"", "\"google-site-verification=3ZcREVrGG9LkdcrAl3h8FxnCJ0IYmg4Ysay8gmUVidQ\""])

  zone_id = local.zone_ids["bensoyka.com"]
  name    = "bensoyka.com"
  type    = "TXT"
  content = each.key
  ttl     = 1
  proxied = false
}

# ------------ ICLOUD MAIL ------------

resource "cloudflare_dns_record" "bensoyka_com_apex_mx" {
  for_each = toset(["mx01.mail.icloud.com", "mx02.mail.icloud.com"])

  zone_id  = local.zone_ids["bensoyka.com"]
  name     = "bensoyka.com"
  type     = "MX"
  content  = each.key
  priority = 10
  ttl      = 1
  proxied  = false
}

# ------------ AWS INCOMING MAIL ------------

resource "cloudflare_dns_record" "bensoyka_com_in_mx" {
  zone_id  = local.zone_ids["bensoyka.com"]
  name     = "in.bensoyka.com"
  type     = "MX"
  content  = "inbound-smtp.us-east-1.amazonaws.com"
  priority = 10
  ttl      = 1
  proxied  = false
}

# ------------ AWS OUTGOING MAIL ------------

resource "cloudflare_dns_record" "bensoyka_com_mail_mx" {
  zone_id  = local.zone_ids["bensoyka.com"]
  name     = "mail.bensoyka.com"
  type     = "MX"
  content  = "feedback-smtp.us-east-1.amazonses.com"
  priority = 10
  ttl      = 1
  proxied  = false
}

# ------------ PROJECT SUBDOMAINS ------------

# Calendar

resource "cloudflare_dns_record" "bensoyka_com_cal_cname" {
  zone_id = local.zone_ids["bensoyka.com"]
  name    = "cal.bensoyka.com"
  type    = "CNAME"
  content = "bsoyka-calendar.pages.dev"
  ttl     = 1
  proxied = true
}

# Gatekeeper

resource "cloudflare_dns_record" "bensoyka_com_gatekeeper_cname" {
  zone_id = local.zone_ids["bensoyka.com"]
  name    = "gatekeeper.bensoyka.com"
  type    = "CNAME"
  content = "di962er6x6fr3.cloudfront.net"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bensoyka_com_a4f4c37292f260b0e602bb62b0f4c3a7_gatekeeper_cname" {
  zone_id = local.zone_ids["bensoyka.com"]
  name    = "_a4f4c37292f260b0e602bb62b0f4c3a7.gatekeeper.bensoyka.com"
  type    = "CNAME"
  content = "_d55cb084945b4096c0d497cd67fad445.jkddzztszm.acm-validations.aws"
  ttl     = 1
  proxied = false
}

# Statistician

resource "cloudflare_dns_record" "bensoyka_com_statistician_cname" {
  zone_id = local.zone_ids["bensoyka.com"]
  name    = "statistician.bensoyka.com"
  type    = "CNAME"
  content = "d-t69wxh4k35.execute-api.us-east-1.amazonaws.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bensoyka_com_773c13740086417b248ad3bcd388ad48_statistician_cname" {
  zone_id = local.zone_ids["bensoyka.com"]
  name    = "_773c13740086417b248ad3bcd388ad48.statistician.bensoyka.com"
  type    = "CNAME"
  content = "_0e06ae0f71f39193689a1eb3f5dca887.jkddzztszm.acm-validations.aws"
  ttl     = 1
  proxied = false
}
