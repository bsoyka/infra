# postoffice is the exit node and advertises the LAN subnet. Advertisement happens
# on the device itself (tailscale up --advertise-routes / --advertise-exit-node) and
# is not manageable from Terraform; this resource only controls which of the
# advertised routes are enabled.
resource "tailscale_device_subnet_routes" "postoffice" {
  device_id = data.tailscale_device.this["postoffice"].node_id

  # An exit node requires both default routes to be listed explicitly.
  routes = ["0.0.0.0/0", "::/0", "100.110.197.128/26"]
}

resource "tailscale_device_key" "postoffice" {
  device_id           = data.tailscale_device.this["postoffice"].node_id
  key_expiry_disabled = true
}
