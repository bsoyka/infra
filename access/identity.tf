# Login methods are all managed by hand in Zero Trust -> Integrations ->
# Identity providers, not here:
#
# - Email code (one-time PIN): already existed on the account.
# - Google and GitHub: each needs an OAuth client secret that would otherwise
#   sit in Terraform state.
# - Cloudflare (sign in with my Cloudflare account).
#
# Applications don't set allowed_idps, so every login method on the account is
# offered. Whichever one is used, the address it reports still has to be in the
# Ben group (or a guest list) to get in. See README.md.
