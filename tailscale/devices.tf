# One data source per device, driven by the devices map in locals.tf. Devices with
# no managed configuration exist only here and in locals.tf; devices that need
# tags, subnet routes, or key-expiry settings get their own device-*.tf file.
data "tailscale_device" "this" {
  for_each = local.devices

  name = each.value
}
