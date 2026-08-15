# hub-construction: https://github.com/bsoyka/hub-construction

resource "cloudflare_workers_custom_domain" "hub_construction" {
  account_id = local.account_id
  zone_id    = local.zone_ids["howlonghasthehubbeenunderconstruction.com"]
  hostname   = "howlonghasthehubbeenunderconstruction.com"
  service    = "hub-construction"
}

resource "cloudflare_workers_kv_namespace" "hub_construction_session" {
  account_id = local.account_id
  title      = "hub-construction-session"
}
