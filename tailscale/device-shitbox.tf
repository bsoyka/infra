# shitbox (Dell Latitude) is always on: a Sirloin backup remote and the planned
# Project NOMAD host. Tagging is a one-way door -- ownership moves to tagged-devices
# and key expiry is disabled for good -- which is also why it has no
# tailscale_device_key resource.
resource "tailscale_device_tags" "shitbox" {
  device_id = data.tailscale_device.this["shitbox"].node_id
  tags      = ["tag:server"]

  # Terraform's graph doesn't know that tag assignment depends on tagOwners in the
  # ACL, so make the ordering explicit.
  depends_on = [tailscale_acl.this]
}
