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

locals {
  # SPF. Zones that send no mail carry "v=spf1 -all" to make that explicit.
  spf_records = {
    "bensoyka.com" = { zone = "bensoyka.com", content = "\"v=spf1 include:icloud.com ~all\"", ttl = 3600 }
    "bsoyka.me"    = { zone = "bsoyka.me", content = "\"v=spf1 include:icloud.com ~all\"", ttl = 3600 }
    "soyka.photos" = { zone = "soyka.photos", content = "\"v=spf1 include:icloud.com ~all\"", ttl = 1 }

    "bsoyka.link"                               = { zone = "bsoyka.link", content = "\"v=spf1 -all\"", ttl = 3600 }
    "headshotguy.net"                           = { zone = "headshotguy.net", content = "\"v=spf1 -all\"", ttl = 3600 }
    "howlonghasthehubbeenunderconstruction.com" = { zone = "howlonghasthehubbeenunderconstruction.com", content = "\"v=spf1 -all\"", ttl = 3600 }
    "mountainspalette.com"                      = { zone = "mountainspalette.com", content = "\"v=spf1 -all\"", ttl = 3600 }

    "lunarleisure.com" = { zone = "lunarleisure.com", content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\"", ttl = 3600 }

    # Sending subdomains, each scoped to its own provider.
    "mail.bensoyka.com" = { zone = "bensoyka.com", content = "\"v=spf1 include:amazonses.com ~all\"", ttl = 1 }
    "mail.bsoyka.me"    = { zone = "bsoyka.me", content = "\"v=spf1 include:spf.anonaddy.me -all\"", ttl = 1 }
  }

  # DMARC. Note the gaps: bsoyka.me, soyka.photos, headshotguy.net,
  # lunarleisure.com, mountainspalette.com and the hub zone have no policy at
  # all, and bsoyka.me's only record covers the mail subdomain rather than the
  # apex, so nothing is inherited.
  dmarc_records = {
    "_dmarc.bensoyka.com"   = { zone = "bensoyka.com", content = "\"v=DMARC1; p=none; rua=mailto:3967fd5120d64c12b77cf3fa5f9400dc@dmarc-reports.cloudflare.net\"", ttl = 1 }
    "_dmarc.bsoyka.link"    = { zone = "bsoyka.link", content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;\"", ttl = 1 }
    "_dmarc.mail.bsoyka.me" = { zone = "bsoyka.me", content = "\"v=DMARC1; p=quarantine; adkim=s\"", ttl = 1 }
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

  # DKIM. Providers publish these either as a CNAME pointing at a key they
  # rotate themselves (iCloud, SES, AnonAddy) or as a TXT holding the key
  # directly (Cloudflare Email).
  dkim_records = merge(local.ses_dkim_records, {
    # iCloud Mail
    "sig1._domainkey.bensoyka.com" = { zone = "bensoyka.com", type = "CNAME", content = "sig1.dkim.bensoyka.com.at.icloudmailadmin.com", ttl = 3600 }
    "sig1._domainkey.bsoyka.me"    = { zone = "bsoyka.me", type = "CNAME", content = "sig1.dkim.bsoyka.me.at.icloudmailadmin.com", ttl = 3600 }
    "sig1._domainkey.soyka.photos" = { zone = "soyka.photos", type = "CNAME", content = "sig1.dkim.soyka.photos.at.icloudmailadmin.com", ttl = 1 }

    # AnonAddy
    "dk1._domainkey.mail.bsoyka.me" = { zone = "bsoyka.me", type = "CNAME", content = "dk1._domainkey.anonaddy.me", ttl = 1 }
    "dk2._domainkey.mail.bsoyka.me" = { zone = "bsoyka.me", type = "CNAME", content = "dk2._domainkey.anonaddy.me", ttl = 1 }

    # A null DKIM key, asserting that nothing legitimately signs for this zone.
    "*._domainkey.bsoyka.link" = { zone = "bsoyka.link", type = "TXT", content = "\"v=DKIM1; p=\"", ttl = 1 }

    # Cloudflare Email Routing
    "cf2024-1._domainkey.lunarleisure.com" = { zone = "lunarleisure.com", type = "TXT", content = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\"", ttl = 1 }
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
