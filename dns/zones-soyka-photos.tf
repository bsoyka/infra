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

# The Pixieset website, apex half. These are the exact two A records Pixieset's
# dashboard specifies for a root domain. They are Cloudflare anycast addresses
# (Pixieset serves custom domains through Cloudflare for SaaS), and they are two
# of the five that domain.pixieset.com currently publishes -- so if Pixieset's
# set ever changes, this pins a subset and the site can break without warning.
#
# Must stay DNS-only: proxying a record whose target is Cloudflare's own address
# space fails with error 1000.
#
# Do NOT add a CAA record to this zone -- it would block the Let's Encrypt
# issuance the certificate for this hostname depends on.
resource "cloudflare_dns_record" "soyka_photos_apex_a" {
  for_each = toset(["104.16.185.173", "104.16.186.173"])

  zone_id = local.zone_ids["soyka.photos"]
  name    = "soyka.photos"
  type    = "A"
  content = each.key
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
  for_each = toset(["\"apple-domain=om9s8FplMGIE4jKs\"", "google-site-verification=nONQnbI9XM2lkVwYx1a1D4ZII8ZjYxUXsN8Lu88WlcI"])

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

# The Pixieset website. Must stay DNS-only so Cloudflare for SaaS can follow
# the CNAME and route the hostname to Pixieset, and so Pixieset can issue the
# certificate for it -- the same arrangement as the gallery record above.
#
# Do NOT add a CAA record to this zone: it would block the Let's Encrypt
# issuance this certificate depends on.
resource "cloudflare_dns_record" "soyka_photos_www_cname" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "www.soyka.photos"
  type    = "CNAME"
  content = "domain.pixieset.com"
  ttl     = 1
  proxied = false
}

# Billing emails via Stripe

resource "cloudflare_dns_record" "soyka_photos_billing_txt" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "billing.soyka.photos"
  type    = "TXT"
  content = "stripe-verification=e60b9386772407e02c0729f3632f18b4de4c5868ef9e5ba428fa62c6ba8f2d89"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "soyka_photos_bounce_billing_cname" {
  zone_id = local.zone_ids["soyka.photos"]
  name    = "bounce.billing.soyka.photos"
  type    = "CNAME"
  content = "custom-email-domain.stripe.com"
  ttl     = 1
  proxied = false
}

# Redirects

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
  ]
}
