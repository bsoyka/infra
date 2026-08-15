terraform {
  backend "s3" {
    bucket       = "bsoyka-tfstate"
    key          = "infra-workers.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
