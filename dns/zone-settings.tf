# Applies the curated zone settings assembled from each zone's file (see
# zones-*.tf) plus the merge in locals.tf.
resource "cloudflare_zone_setting" "this" {
  for_each = local.zone_settings

  zone_id    = local.zone_ids[each.value.zone]
  setting_id = each.value.setting_id
  value      = each.value.value
}
