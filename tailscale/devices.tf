# One data source per device, driven by the devices map in locals.tf. Devices with
# no managed configuration exist only here and in locals.tf; devices that need
# tags, subnet routes, or key-expiry settings get their own device-*.tf file.
data "tailscale_device" "this" {
  for_each = local.devices

  name = each.value
}

# ------------ RETIRED DEVICES ------------

# townhall (IONOS VPS) was decommissioned in Nov 2026 and has left the tailnet
# (trailhead also left, but had no managed resources -- dropping it from
# local.devices was enough).
# Forget its tag resource without trying to change a device that no longer exists.
# Safe to delete this block once the apply that removes it from state has run.
removed {
  from = tailscale_device_tags.townhall

  lifecycle {
    destroy = false
  }
}
