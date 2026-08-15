# Credentials come from the TAILSCALE_OAUTH_CLIENT_ID / TAILSCALE_OAUTH_CLIENT_SECRET /
# TAILSCALE_TAILNET environment variables, which the provider reads natively. See
# tailscale/README.md.
provider "tailscale" {}
