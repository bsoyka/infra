# Catch-all: every subdomain of bensoyka.net is mine-only unless a more
# specific application below says otherwise. Access matches the most
# specific application for a hostname, so a new tool on this domain is
# protected the moment it gets DNS, with nothing else to remember.
resource "cloudflare_zero_trust_access_application" "bensoyka_net" {
  account_id       = local.account_id
  name             = "bensoyka.net (catch-all)"
  type             = "self_hosted"
  session_duration = local.session_duration

  destinations = [
    { type = "public", uri = "*.bensoyka.net" },
  ]

  policies = [
    { id = cloudflare_zero_trust_access_policy.ben.id, precedence = 1 },
  ]

  app_launcher_visible = false
}

# upload.bensoyka.net: the share-upload Worker (bsoyka/share-upload). Me in a
# browser, the CLI by service token, and any guests.
resource "cloudflare_zero_trust_access_application" "upload" {
  account_id       = local.account_id
  name             = "Upload (share.bensoyka.com)"
  type             = "self_hosted"
  session_duration = local.session_duration

  destinations = [
    { type = "public", uri = "upload.bensoyka.net" },
  ]

  policies = concat(
    [
      { id = cloudflare_zero_trust_access_policy.ben.id, precedence = 1 },
      { id = cloudflare_zero_trust_access_policy.service_tokens.id, precedence = 2 },
    ],
    [for p in cloudflare_zero_trust_access_policy.upload_guests : { id = p.id, precedence = 3 }],
  )

  app_launcher_visible = true
}

# The apex is the one public page: a landing page saying what the domain is
# for and linking to bensoyka.com (workers/workers-bensoyka-net.tf). Bypass
# means no login and no Access JWT.
resource "cloudflare_zero_trust_access_application" "bensoyka_net_apex" {
  account_id = local.account_id
  name       = "bensoyka.net landing page (public)"
  type       = "self_hosted"

  destinations = [
    { type = "public", uri = "bensoyka.net" },
  ]

  policies = [
    { id = cloudflare_zero_trust_access_policy.everyone_bypass.id, precedence = 1 },
  ]

  app_launcher_visible = false
}
