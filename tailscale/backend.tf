terraform {
  backend "s3" {
    bucket       = "bsoyka-tfstate"
    key          = "infra-tailscale.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
