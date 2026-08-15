resource "tailscale_dns_configuration" "this" {
  magic_dns          = true
  override_local_dns = false
  search_paths       = []
}
