# soyka.photos: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  soyka_photos_settings = {
    "soyka.photos/always_online"            = { zone = "soyka.photos", setting_id = "always_online", value = "off" }
    "soyka.photos/always_use_https"         = { zone = "soyka.photos", setting_id = "always_use_https", value = "off" }
    "soyka.photos/automatic_https_rewrites" = { zone = "soyka.photos", setting_id = "automatic_https_rewrites", value = "on" }
    "soyka.photos/brotli"                   = { zone = "soyka.photos", setting_id = "brotli", value = "on" }
    "soyka.photos/browser_check"            = { zone = "soyka.photos", setting_id = "browser_check", value = "on" }
    "soyka.photos/challenge_ttl"            = { zone = "soyka.photos", setting_id = "challenge_ttl", value = 1800 }
    "soyka.photos/early_hints"              = { zone = "soyka.photos", setting_id = "early_hints", value = "off" }
    "soyka.photos/hotlink_protection"       = { zone = "soyka.photos", setting_id = "hotlink_protection", value = "off" }
    "soyka.photos/min_tls_version"          = { zone = "soyka.photos", setting_id = "min_tls_version", value = "1.0" }
    "soyka.photos/opportunistic_encryption" = { zone = "soyka.photos", setting_id = "opportunistic_encryption", value = "on" }
    "soyka.photos/rocket_loader"            = { zone = "soyka.photos", setting_id = "rocket_loader", value = "off" }
    "soyka.photos/security_level"           = { zone = "soyka.photos", setting_id = "security_level", value = "medium" }
    "soyka.photos/ssl"                      = { zone = "soyka.photos", setting_id = "ssl", value = "full" }
    "soyka.photos/tls_1_3"                  = { zone = "soyka.photos", setting_id = "tls_1_3", value = "on" }
  }
}

resource "cloudflare_dns_record" "soyka_photos_apex_a" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "soyka.photos"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "soyka_photos_apex_mx" {
  for_each = toset(["mx01.mail.icloud.com", "mx02.mail.icloud.com"])

  zone_id  = local.zone_ids["soyka.photos"]
  name     = "soyka.photos"
  type     = "MX"
  content  = each.key
  priority = 10
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "soyka_photos_apex_txt" {
  for_each = toset(["\"apple-domain=om9s8FplMGIE4jKs\"", "\"v=spf1 include:icloud.com ~all\""])

  zone_id = local.zone_ids["soyka.photos"]
  name    = "soyka.photos"
  type    = "TXT"
  content = each.key
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "soyka_photos_chat_a" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "chat.soyka.photos"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "soyka_photos_gallery_cname" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "gallery.soyka.photos"
  type    = "CNAME"
  content = "domain.pixieset.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "soyka_photos_sig1_domainkey_cname" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "sig1._domainkey.soyka.photos"
  type    = "CNAME"
  content = "sig1.dkim.soyka.photos.at.icloudmailadmin.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "soyka_photos_www_a" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "www.soyka.photos"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "soyka_photos_redirects" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "28620cea81844b0c883caadb991527de"
      description = "Consultation subdomain"
      expression  = "(http.host eq \"chat.soyka.photos\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            value = "https://cal.com/bsoyka/photography"
          }
        }
      }
    },
    {
      ref         = "218f6a841cab46688d7f9eeeeb02dd6b"
      description = "Redirect to photos.bsoyka.me"
      expression  = "(http.host eq \"soyka.photos\") or (http.host eq \"www.soyka.photos\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 302
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://photos.bsoyka.me\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
