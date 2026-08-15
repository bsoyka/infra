resource "tailscale_device_tags" "townhall" {
  device_id = data.tailscale_device.this["townhall"].node_id
  tags      = ["tag:prod", "tag:server"]

  # Terraform's graph doesn't know that tag assignment depends on tagOwners in the
  # ACL, so make the ordering explicit.
  depends_on = [tailscale_acl.this]
}
