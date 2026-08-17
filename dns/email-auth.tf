# Email authentication (SPF, DMARC, DKIM) for every zone.
#
# These records are gathered here rather than in the per-zone zones-*.tf files
# because they are the one class of record that has to be reasoned about as a
# set: the same policy tends to apply across several zones at once, and a change
# to one is usually a change to all of them. Everything else about a zone still
# lives in its own file (see README.md).
#
# Keys are the fully-qualified name that carries the record, so a hostname can
# be found by searching for it directly.
#
# TXT values are written bare. Cloudflare treats surrounding quotes as
# delimiters and strips them, so "v=spf1 -all" and "\"v=spf1 -all\"" serve the
# identical record -- the escaping was noise.
#
# The one case that would need quotes is a value longer than 255 bytes, the DNS
# limit for a single TXT character-string: interior quotes split it into several.
# No record here is that long today, but a real (rather than null) DKIM key
# would be, so keep it in mind before adding one.

locals {
  # SPF. Zones that send no mail carry "v=spf1 -all" to make that explicit.
  spf_records = {
    "bensoyka.com" = { zone = "bensoyka.com", content = "v=spf1 include:icloud.com ~all", ttl = 1 }
    "bsoyka.me"    = { zone = "bsoyka.me", content = "v=spf1 include:icloud.com ~all", ttl = 1 }
    "soyka.photos" = { zone = "soyka.photos", content = "v=spf1 include:icloud.com ~all", ttl = 1 }

    "bsoyka.link"                               = { zone = "bsoyka.link", content = "v=spf1 -all", ttl = 1 }
    "headshotguy.net"                           = { zone = "headshotguy.net", content = "v=spf1 -all", ttl = 1 }
    "howlonghasthehubbeenunderconstruction.com" = { zone = "howlonghasthehubbeenunderconstruction.com", content = "v=spf1 -all", ttl = 1 }
    "lunarleisure.com"                          = { zone = "lunarleisure.com", content = "v=spf1 -all", ttl = 1 }
    "mountainspalette.com"                      = { zone = "mountainspalette.com", content = "v=spf1 -all", ttl = 1 }

    # Sending subdomains, each scoped to its own provider.
    "mail.bensoyka.com" = { zone = "bensoyka.com", content = "v=spf1 include:amazonses.com ~all", ttl = 1 }
    "mail.bsoyka.me"    = { zone = "bsoyka.me", content = "v=spf1 include:spf.anonaddy.me -all", ttl = 1 }
  }

  # DMARC. Zones that carry live mail sit at p=quarantine with relaxed
  # alignment (the spec default), so a subdomain sender that hasn't been
  # accounted for fails soft rather than disappearing. Zones that send nothing
  # use p=reject with strict alignment -- there is no legitimate mail to lose,
  # and the strict pairing is what makes "v=spf1 -all" actually enforceable.
  #
  # Only bensoyka.com reports: its rua address is issued per-zone by Cloudflare
  # DMARC Management and can't be reused, and the other zones were set without
  # reporting rather than each needing its own dashboard step.
  dmarc_records = {
    # Zones that send mail.
    "_dmarc.bensoyka.com"   = { zone = "bensoyka.com", content = "v=DMARC1; p=quarantine; rua=mailto:3967fd5120d64c12b77cf3fa5f9400dc@dmarc-reports.cloudflare.net", ttl = 1 }
    "_dmarc.bsoyka.me"      = { zone = "bsoyka.me", content = "v=DMARC1; p=quarantine", ttl = 1 }
    "_dmarc.soyka.photos"   = { zone = "soyka.photos", content = "v=DMARC1; p=quarantine", ttl = 1 }
    "_dmarc.billing.soyka.photos"   = { zone = "soyka.photos", content = "v=DMARC1; p=quarantine", ttl = 1 }
    "_dmarc.mail.bsoyka.me" = { zone = "bsoyka.me", content = "v=DMARC1; p=quarantine; adkim=s", ttl = 1 }

    # Zones that send nothing.
    "_dmarc.bsoyka.link"                               = { zone = "bsoyka.link", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;", ttl = 1 }
    "_dmarc.headshotguy.net"                           = { zone = "headshotguy.net", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;", ttl = 1 }
    "_dmarc.howlonghasthehubbeenunderconstruction.com" = { zone = "howlonghasthehubbeenunderconstruction.com", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;", ttl = 1 }
    "_dmarc.lunarleisure.com"                          = { zone = "lunarleisure.com", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;", ttl = 1 }
    "_dmarc.mountainspalette.com"                      = { zone = "mountainspalette.com", content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;", ttl = 1 }
  }

  # Amazon SES rotates these as a set; they are generated into dkim_records
  # below rather than listed one by one.
  ses_dkim_selectors = [
    "bntozggc32fnqppxzjdgucm3uovji2v7",
    "jvs36w4jzarwc2l4qxcbepexcsshtkvk",
    "k74wsifysejy46o3w757f7tpb72qtmtt",
  ]

  ses_dkim_records = {
    for selector in local.ses_dkim_selectors :
    "${selector}._domainkey.bensoyka.com" => {
      zone    = "bensoyka.com"
      type    = "CNAME"
      content = "${selector}.dkim.amazonses.com"
      ttl     = 1
    }
  }

  # Same for Stripe for billing.soyka.photos
  stripe_dkim_selectors = [
    "fksu5m54ythtjwubngwdc6jnahuj5nst",
    "rd5qllmixrpjargmkwxlah5l4457vmwr",
    "k3irg2fr2f4k6lbkezcn5xrmkzfdvlfa",
    "jurncgwqjjqzvlotik6a5tpdd7h23rhy",
    "veshtb7a6ueqk3sf2eq3clkkrg5qna4e",
    "5tv7qxxgaoayg4ss7df5gl23dbbryjqq"
  ]

  stripe_dkim_records = {
    for selector in local.stripe_dkim_selectors :
    "${selector}._domainkey.billing.soyka.photos" => {
      zone    = "soyka.photos"
      type    = "CNAME"
      content = "${selector}.dkim.custom-email-domain.stripe.com."
      ttl     = 1
    }
  }

  # DKIM. Providers publish these either as a CNAME pointing at a key they
  # rotate themselves (iCloud, SES, AnonAddy) or as a TXT holding the key
  # directly (Cloudflare Email).
  dkim_records = merge(local.ses_dkim_records, local.stripe_dkim_records, {
    # iCloud Mail
    "sig1._domainkey.bensoyka.com" = { zone = "bensoyka.com", type = "CNAME", content = "sig1.dkim.bensoyka.com.at.icloudmailadmin.com", ttl = 1 }
    "sig1._domainkey.bsoyka.me"    = { zone = "bsoyka.me", type = "CNAME", content = "sig1.dkim.bsoyka.me.at.icloudmailadmin.com", ttl = 1 }
    "sig1._domainkey.soyka.photos" = { zone = "soyka.photos", type = "CNAME", content = "sig1.dkim.soyka.photos.at.icloudmailadmin.com", ttl = 1 }

    # AnonAddy
    "dk1._domainkey.mail.bsoyka.me" = { zone = "bsoyka.me", type = "CNAME", content = "dk1._domainkey.anonaddy.me", ttl = 1 }
    "dk2._domainkey.mail.bsoyka.me" = { zone = "bsoyka.me", type = "CNAME", content = "dk2._domainkey.anonaddy.me", ttl = 1 }

    # Null DKIM keys: an empty p= asserts that no key can validly sign for these
    # zones, which is what completes the p=reject posture above.
    "*._domainkey.bsoyka.link"                               = { zone = "bsoyka.link", type = "TXT", content = "v=DKIM1; p=", ttl = 1 }
    "*._domainkey.headshotguy.net"                           = { zone = "headshotguy.net", type = "TXT", content = "v=DKIM1; p=", ttl = 1 }
    "*._domainkey.howlonghasthehubbeenunderconstruction.com" = { zone = "howlonghasthehubbeenunderconstruction.com", type = "TXT", content = "v=DKIM1; p=", ttl = 1 }
    "*._domainkey.lunarleisure.com"                          = { zone = "lunarleisure.com", type = "TXT", content = "v=DKIM1; p=", ttl = 1 }
    "*._domainkey.mountainspalette.com"                      = { zone = "mountainspalette.com", type = "TXT", content = "v=DKIM1; p=", ttl = 1 }
  })
}

resource "cloudflare_dns_record" "spf" {
  for_each = local.spf_records

  zone_id = local.zone_ids[each.value.zone]
  name    = each.key
  type    = "TXT"
  content = each.value.content
  ttl     = each.value.ttl
  proxied = false
}

resource "cloudflare_dns_record" "dmarc" {
  for_each = local.dmarc_records

  zone_id = local.zone_ids[each.value.zone]
  name    = each.key
  type    = "TXT"
  content = each.value.content
  ttl     = each.value.ttl
  proxied = false
}

resource "cloudflare_dns_record" "dkim" {
  for_each = local.dkim_records

  zone_id = local.zone_ids[each.value.zone]
  name    = each.key
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl
  proxied = false
}
