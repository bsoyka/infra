# One resource per zone, driven by the zone_ids map in locals.tf. prevent_destroy
# guards against a stray plan tearing down a zone (and every record in it).
resource "cloudflare_zone" "this" {
  for_each = local.zone_ids

  name = each.key
  type = "full"

  account = {
    id = local.account_id
  }

  lifecycle {
    prevent_destroy = true
  }
}
