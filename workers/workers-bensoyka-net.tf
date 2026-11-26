# bensoyka.net landing page: the one public page on bensoyka.net, saying the
# domain is for my own tools and pointing to bensoyka.com. Access lets the apex
# through without a login (access/apps.tf); every subdomain still needs one.
#
# Unlike the other Workers here, the script itself is managed in this repo:
# it's a single static file with no build step, so none of the reasons in
# README.md for keeping scripts out of Terraform apply.

resource "cloudflare_workers_script" "bensoyka_net_landing" {
  account_id         = local.account_id
  script_name        = "bensoyka-net-landing"
  main_module        = "index.js"
  content_file       = "${path.module}/landing-bensoyka-net/index.js"
  content_sha256     = filesha256("${path.module}/landing-bensoyka-net/index.js")
  compatibility_date = "2026-11-01"
}

resource "cloudflare_workers_custom_domain" "bensoyka_net_landing" {
  account_id = local.account_id
  zone_id    = local.zone_ids["bensoyka.net"]
  hostname   = "bensoyka.net"
  service    = cloudflare_workers_script.bensoyka_net_landing.script_name
}
