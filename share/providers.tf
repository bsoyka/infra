# Credentials come from the usual AWS environment (the same ones used for the
# state bucket). Everything lives in us-east-1 because CloudFront only accepts
# ACM certificates from that region.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "share"
      ManagedBy = "bsoyka/infra"
    }
  }
}
