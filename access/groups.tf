# "Ben": every email address on my current PGP key. scripts/pgp-emails.sh
# fetches the published key, refuses it unless the fingerprint matches
# local.pgp_key.fingerprint, and returns the addresses of user IDs that aren't
# revoked or expired.
#
# This is read at plan time, so adding a UID to the key (or revoking one) takes
# effect on the next apply, not live.

data "external" "pgp_emails" {
  program = ["${path.module}/scripts/pgp-emails.sh"]
  query   = local.pgp_key
}

locals {
  ben_emails = sort(split(",", data.external.pgp_emails.result.emails))
}

resource "cloudflare_zero_trust_access_group" "ben" {
  account_id = local.account_id
  name       = "Ben"

  include = [for e in local.ben_emails : { email = { email = e } }]
}

# Reusable policies.

resource "cloudflare_zero_trust_access_policy" "ben" {
  account_id = local.account_id
  name       = "Ben"
  decision   = "allow"

  include = [{ group = { id = cloudflare_zero_trust_access_group.ben.id } }]
}

# Machine clients (no login page): any valid service token on the account.
# Tokens are made by hand (README.md) so their secrets never land in state.
#
# This lets in *every* token on the account, so each app that uses it must
# also check which token it got: Access puts the token's client ID in the
# JWT's common_name, and the share-upload Worker only accepts the client IDs
# in its ALLOWED_SERVICE_TOKENS var. Matching a specific token here would
# need its token ID (a UUID), which the dashboard doesn't readily show.
resource "cloudflare_zero_trust_access_policy" "service_tokens" {
  account_id = local.account_id
  name       = "Any service token (app checks which)"
  decision   = "non_identity"

  include = [{ any_valid_service_token = {} }]
}

resource "cloudflare_zero_trust_access_policy" "upload_guests" {
  count = length(local.upload_guests) > 0 ? 1 : 0

  account_id = local.account_id
  name       = "upload.bensoyka.net guests"
  decision   = "allow"

  include = [for e in local.upload_guests : { email = { email = e } }]
}

# Public pages: no login at all.
resource "cloudflare_zero_trust_access_policy" "everyone_bypass" {
  account_id = local.account_id
  name       = "Everyone (bypass)"
  decision   = "bypass"

  include = [{ everyone = {} }]
}
