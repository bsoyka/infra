locals {
  account_id = "c13c82492d318fee88e1d77400282706"

  # Zone IDs, kept here so record files can reference zones without depending on
  # the cloudflare_zone resources' creation order.
  zone_ids = {
    "bensoyka.com"                              = "c0e27eb0bfcc5e664c3bc8f3019167ad"
    "bsoyka.link"                               = "f1f31755dacf5bfb75f1e4ab6c7c671b"
    "bsoyka.me"                                 = "8c2a35e47279bf4b28daaec46b569b57"
    "headshotguy.net"                           = "a593b179391fe94601df4aea4763007e"
    "howlonghasthehubbeenunderconstruction.com" = "9a20cb9814d9dffbdfe93e4c5f9e99e1"
    "lunarleisure.com"                          = "deb3dc00bd0669f71cff08b471eab33a"
    "mountainspalette.com"                      = "f31b259b848b511db6072887416dd92f"
    "soyka.photos"                              = "a3168e7d47d4847280fcac3844083f68"
  }

  # Curated zone settings (TLS/HTTPS security core pinned everywhere, plus a
  # handful of other settings that already diverge per zone), assembled from
  # each zone's file.
  zone_settings = merge(local.bsoyka_me_settings, local.bensoyka_com_settings, local.soyka_photos_settings, local.lunarleisure_com_settings, local.mountainspalette_com_settings, local.bsoyka_link_settings, local.headshotguy_net_settings, local.hub_construction_settings)
}
