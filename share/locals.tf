locals {
  domain      = "share.bensoyka.com"
  bucket_name = "bsoyka-share"

  # One prefix per uploading client. Each client's IAM user can only write
  # under its own prefix, and each prefix has its own retention.
  prefixes = {
    shottr = { path = "screenshot/", expire_days = 90 }
    mail   = { path = "mail/", expire_days = 60 }
  }
}
