locals {
  account_id = "c13c82492d318fee88e1d77400282706"

  # How long a sign-in lasts on a device before Access asks again.
  session_duration = "720h" # 30 days

  # My PGP key is the source of truth for which addresses are "me" (see
  # groups.tf). The fingerprint is pinned here, not fetched, so a swapped key
  # at the URL fails the plan instead of quietly changing who gets in.
  pgp_key = {
    url         = "https://keys.bensoyka.com/pgp.asc"
    fingerprint = "BC4876BDC8AB5AB8C9CB81659497E30583D68D89"
  }

  # People other than me who may use upload.bensoyka.net. Leave empty when
  # nobody is. They sign in with whatever IdP matches their address (usually
  # the one-time email code).
  upload_guests = []
}
