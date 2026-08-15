# soyka.photos: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  soyka_photos_settings = {
    "soyka.photos/always_online"            = { zone = "soyka.photos", setting_id = "always_online", value = "off" }
    "soyka.photos/always_use_https"         = { zone = "soyka.photos", setting_id = "always_use_https", value = "on" }
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

# The Pixieset website. Pixieset serves custom domains through Cloudflare for
# SaaS, so this record must stay DNS-only: proxying a record whose target is
# Cloudflare's own address space fails with error 1000.
#
# Pixieset's dashboard asks for two A records (104.16.185.173, 104.16.186.173),
# but those are two of the five addresses domain.pixieset.com publishes, and
# they're Cloudflare anycast IPs rather than Pixieset's own. A CNAME here is
# flattened at the root by Cloudflare, so it tracks whatever Pixieset publishes
# instead of pinning a subset that can change out from under us.
#
# Do NOT add a CAA record to this zone -- it would block the Let's Encrypt
# issuance this hostname's certificate depends on.
resource "cloudflare_dns_record" "soyka_photos_apex_cname" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "soyka.photos"
  type    = "CNAME"
  content = "domain.pixieset.com"
  ttl     = 1
  proxied = false
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

# Stays a proxied placeholder: it never serves the site, it only redirects to
# the apex (see the ruleset below), which requires proxied traffic.
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
      ref         = "www_to_apex"
      description = "www.soyka.photos/* -> soyka.photos/*"
      expression  = "(http.host eq \"www.soyka.photos\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://soyka.photos\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
