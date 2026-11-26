# groundstation (Raspberry Pi, formerly postoffice) is the exit node. Advertisement
# happens on the device itself (tailscale set --advertise-exit-node) and is not
# manageable from Terraform; this resource only controls which of the advertised
# routes are enabled.
resource "tailscale_device_subnet_routes" "groundstation" {
  device_id = data.tailscale_device.this["groundstation"].node_id

  # An exit node requires both default routes to be listed explicitly. The LAN
  # subnet route (100.110.197.128/26, for the printer) was dropped: the building's
  # network is CGNAT space that overlaps Tailscale's 100.64.0.0/10.
  routes = ["0.0.0.0/0", "::/0"]
}

# Tagging is a one-way door: ownership moves from bensoyka6@ to tagged-devices and
# key expiry is disabled for good.
resource "tailscale_device_tags" "groundstation" {
  device_id = data.tailscale_device.this["groundstation"].node_id
  tags      = ["tag:server"]

  # Terraform's graph doesn't know that tag assignment depends on tagOwners in the
  # ACL, so make the ordering explicit.
  depends_on = [tailscale_acl.this]
}
