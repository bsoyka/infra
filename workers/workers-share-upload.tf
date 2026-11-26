# share-upload: https://github.com/bsoyka/share-upload
#
# Upload page and API for share.bensoyka.com. The hostname is protected by
# Cloudflare Access (access/apps-upload.tf); the Worker also checks the Access
# JWT itself.

resource "cloudflare_workers_custom_domain" "share_upload" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bensoyka.net"]
  hostname   = "upload.bensoyka.net"
  service    = "share-upload"
}
