# ------------ TAG OWNERS ------------

locals {
  acl_tag_owners = {
    "tag:server" = ["autogroup:admin"]
    "tag:prod"   = ["autogroup:admin"]
    "tag:ci"     = ["autogroup:admin"]
  }
}

# ------------ GRANTS ------------

locals {
  acl_grants = [
    {
      src = ["autogroup:admin"]
      dst = ["*"]
      ip  = ["*"]
    },
  ]
}

# ------------ SSH ------------

locals {
  acl_ssh = [
    # Allow all users to SSH into their own devices in check mode.
    {
      action = "check"
      src    = ["autogroup:member"]
      dst    = ["autogroup:self"]
      users  = ["autogroup:nonroot", "root"]
    },
    {
      action = "accept"
      src    = ["autogroup:admin"]
      dst    = ["tag:prod"]
      users  = ["autogroup:nonroot", "root"]
    },
    {
      action = "accept"
      src    = ["tag:ci"]
      dst    = ["tag:prod"]
      users  = ["autogroup:nonroot"]
    },
  ]
}

# ------------ POLICY ------------

# The Tailscale API's JSON policy validation doesn't accept a "//" note key (that's
# a HuJSON-only convention understood by the console/CLI, not the write endpoint),
# so this comment is the only place noting: managed by Terraform, see
# https://github.com/bsoyka/infra/tree/main/tailscale.
resource "tailscale_acl" "this" {
  acl = jsonencode({
    tagOwners = local.acl_tag_owners
    grants    = local.acl_grants
    ssh       = local.acl_ssh
  })
}
