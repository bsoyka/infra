# bsoyka.me: DNS records, zone settings, and redirects.

locals {
  # This zone's slice of the curated zone settings (see locals.tf).
  bsoyka_me_settings = {
    "bsoyka.me/always_online"            = { zone = "bsoyka.me", setting_id = "always_online", value = "on" }
    "bsoyka.me/always_use_https"         = { zone = "bsoyka.me", setting_id = "always_use_https", value = "on" }
    "bsoyka.me/automatic_https_rewrites" = { zone = "bsoyka.me", setting_id = "automatic_https_rewrites", value = "on" }
    "bsoyka.me/brotli"                   = { zone = "bsoyka.me", setting_id = "brotli", value = "on" }
    "bsoyka.me/browser_check"            = { zone = "bsoyka.me", setting_id = "browser_check", value = "on" }
    "bsoyka.me/challenge_ttl"            = { zone = "bsoyka.me", setting_id = "challenge_ttl", value = 1800 }
    "bsoyka.me/early_hints"              = { zone = "bsoyka.me", setting_id = "early_hints", value = "on" }
    "bsoyka.me/hotlink_protection"       = { zone = "bsoyka.me", setting_id = "hotlink_protection", value = "on" }
    "bsoyka.me/min_tls_version"          = { zone = "bsoyka.me", setting_id = "min_tls_version", value = "1.0" }
    "bsoyka.me/opportunistic_encryption" = { zone = "bsoyka.me", setting_id = "opportunistic_encryption", value = "on" }
    "bsoyka.me/rocket_loader"            = { zone = "bsoyka.me", setting_id = "rocket_loader", value = "on" }
    "bsoyka.me/security_level"           = { zone = "bsoyka.me", setting_id = "security_level", value = "medium" }
    "bsoyka.me/ssl"                      = { zone = "bsoyka.me", setting_id = "ssl", value = "flexible" }
    "bsoyka.me/tls_1_3"                  = { zone = "bsoyka.me", setting_id = "tls_1_3", value = "on" }
  }
}


locals {
  # Stripe custom email domain DKIM keys for photos.bsoyka.me.
  stripe_dkim_selectors = [
    "32cgak2j6zrodgxbqmu7bkpydihgtiah",
    "55ig7coarsaa4kyt672rpplv3xrgnmct",
    "jcljrmdds7wblxqjzn5kenl324szs62d",
    "jizbuf4gmk55h3inxhfl2crqb3vlwpe7",
    "mqtggxlhtf6til3zkdptjawbizsrmofr",
    "u75lkntaf5tjxpxi4ly2bh7vnfye472y",
  ]
}
resource "cloudflare_dns_record" "bsoyka_me_aoc_ocr_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "aoc-ocr.bsoyka.me"
  type    = "CNAME"
  content = "readthedocs.io"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_apex_aaaa" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "bsoyka.me"
  type    = "AAAA"
  content = "100::"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_apex_mx" {
  for_each = toset(["mx01.mail.icloud.com", "mx02.mail.icloud.com"])

  zone_id  = local.zone_ids["bsoyka.me"]
  name     = "bsoyka.me"
  type     = "MX"
  content  = each.key
  priority = 10
  ttl      = 3600
  proxied  = false
}

resource "cloudflare_dns_record" "bsoyka_me_apex_txt" {
  for_each = toset(["\"MS=ms91612553\"", "\"abuseipdb-verification=fBJQRaKN\"", "\"apple-domain=95jSfw1eSMgiCbnX\"", "\"apple-domain=GlJq0rCqk0wARSgv\"", "\"apple-domain=Mmk69XPD4Sj7l2cn\"", "\"google-site-verification=div3eS2o7A0sZgTmGk_CrQ8ZzbxvhWhcXWb-1l1iT7U\"", "\"keybase-site-verification=8mkbKsdi1n4xnqWPXlqea0nQ3r29ltiNcSn1_TugKvU\"", "\"pinterest-site-verification=6743ee9d28ca9087c198e888f0554028\"", "\"v=spf1 include:icloud.com ~all\""])

  zone_id = local.zone_ids["bsoyka.me"]
  name    = "bsoyka.me"
  type    = "TXT"
  content = each.key
  ttl     = 3600
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_api_a" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "api.bsoyka.me"
  type    = "A"
  content = "66.179.93.20"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_atproto_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_atproto.bsoyka.me"
  type    = "TXT"
  content = "\"did=did:plc:qmjmer2bnqktri7d572rd22z\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_bounce_photos_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "bounce.photos.bsoyka.me"
  type    = "CNAME"
  content = "custom-email-domain.stripe.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_cal_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "cal.bsoyka.me"
  type    = "CNAME"
  content = "bsoyka-calendar.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_dk1_domainkey_mail_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "dk1._domainkey.mail.bsoyka.me"
  type    = "CNAME"
  content = "dk1._domainkey.anonaddy.me"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_dk2_domainkey_mail_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "dk2._domainkey.mail.bsoyka.me"
  type    = "CNAME"
  content = "dk2._domainkey.anonaddy.me"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_dmarc_mail_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_dmarc.mail.bsoyka.me"
  type    = "TXT"
  content = "\"v=DMARC1; p=quarantine; adkim=s\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_dmarc_photos_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_dmarc.photos.bsoyka.me"
  type    = "TXT"
  content = "v=DMARC1; p=none"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_doppler_zvsrldgyfvua4_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_doppler_zvsrldgyfvua4.bsoyka.me"
  type    = "TXT"
  content = "Cn1GYDQk9TdSoWR04xbKFOwqs1YOD0Px"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_evil_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "evil.bsoyka.me"
  type    = "CNAME"
  content = "evil.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_gallery_a" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "gallery.bsoyka.me"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_gh_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "gh.bsoyka.me"
  type    = "CNAME"
  content = "bsoyka.me"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_github_challenge_mystery_egg_mysteryegg_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_github-challenge-mystery-egg.mysteryegg.bsoyka.me"
  type    = "TXT"
  content = "8880f8886f"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_github_challenge_mystery_egg_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_github-challenge-mystery-egg.bsoyka.me"
  type    = "TXT"
  content = "0b43a86b06"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_github_pages_challenge_bsoyka_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_github-pages-challenge-bsoyka.bsoyka.me"
  type    = "TXT"
  content = "05613dad04b49e889792dbcef66db9"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_hello_pka_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "hello._pka.bsoyka.me"
  type    = "TXT"
  content = "v=pka1;fpr=0CA7CC16A64B68F3048EE8FEA5E726D5A65228EA;uri=https://bsoyka.me/key.asc"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_mail_mx" {
  for_each = { "mail.anonaddy.me" = 10, "mail2.anonaddy.me" = 20 }

  zone_id  = local.zone_ids["bsoyka.me"]
  name     = "mail.bsoyka.me"
  type     = "MX"
  content  = each.key
  priority = each.value
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "bsoyka_me_mail_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "mail.bsoyka.me"
  type    = "TXT"
  content = "\"v=spf1 include:spf.anonaddy.me -all\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_mc_a" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "mc.bsoyka.me"
  type    = "A"
  content = "51.81.50.202"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_medium_a" {
  for_each = toset(["162.159.152.4", "162.159.153.4"])

  zone_id = local.zone_ids["bsoyka.me"]
  name    = "medium.bsoyka.me"
  type    = "A"
  content = each.key
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_medium_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "medium.bsoyka.me"
  type    = "TXT"
  content = "pinterest-site-verification=6743ee9d28ca9087c198e888f0554028"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_minecraft_tcp_mc_srv" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "_minecraft._tcp.mc.bsoyka.me"
  type    = "SRV"
  data = {
    port     = 24812
    priority = 0
    target   = "mc.bsoyka.me"
    weight   = 0
  }
  priority = 0
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "bsoyka_me_mysteryegg_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "mysteryegg.bsoyka.me"
  type    = "CNAME"
  content = "mystery-egg.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "bsoyka_me_photos_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "photos.bsoyka.me"
  type    = "CNAME"
  content = "domain.pixieset.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_photos_stripe_dkim" {
  for_each = toset(local.stripe_dkim_selectors)

  zone_id = local.zone_ids["bsoyka.me"]
  name    = "${each.key}._domainkey.photos.bsoyka.me"
  type    = "CNAME"
  content = "${each.key}.dkim.custom-email-domain.stripe.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_photos_txt" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "photos.bsoyka.me"
  type    = "TXT"
  content = "\"stripe-verification=e60b9386772407e02c0729f3632f18b4de4c5868ef9e5ba428fa62c6ba8f2d89\""
  ttl     = 3600
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_sig1_domainkey_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "sig1._domainkey.bsoyka.me"
  type    = "CNAME"
  content = "sig1.dkim.bsoyka.me.at.icloudmailadmin.com"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_wb_cname" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "wb.bsoyka.me"
  type    = "CNAME"
  content = "ghs.googlehosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "bsoyka_me_www_aaaa" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "www.bsoyka.me"
  type    = "AAAA"
  content = "100::"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "bsoyka_me_redirects" {
  zone_id = local.zone_ids["bsoyka.me"]
  name    = "default"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "fca7c5af7ac940ae9af3e51fb4a8a973"
      description = "Redirect gallery"
      expression  = "(http.host eq \"gallery.bsoyka.me\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://gallery.soyka.photos\", http.request.uri.path)"
          }
        }
      }
    },
    {
      ref         = "gh_to_github"
      description = "gh.bsoyka.me/* -> github.com/bsoyka/*"
      expression  = "(http.host eq \"gh.bsoyka.me\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://github.com/bsoyka\", http.request.uri.path)"
          }
        }
      }
    },
    {
      ref         = "blog_to_bsoyka_me_blog"
      description = "blog.bsoyka.me/* -> bsoyka.me/blog/*"
      expression  = "(http.host eq \"blog.bsoyka.me\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://bsoyka.me/blog\", http.request.uri.path)"
          }
        }
      }
    },
  ]
}
