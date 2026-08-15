terraform {
  required_version = "~> 1.15.8"
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29"
    }
  }
}
