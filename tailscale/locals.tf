locals {
  tailnet         = "bensoyka6@gmail.com"
  magicdns_suffix = "broadbill-gecko.ts.net"

  # Devices owned by this tailnet, short name => MagicDNS name. Keyed on the full
  # name rather than hostname -- several devices' hostnames are generic (localhost,
  # ipad, ubuntu) and would be ambiguous or collide with a future device.
  devices = {
    trailhead  = "trailhead.${local.magicdns_suffix}"
    townsquare = "townsquare.${local.magicdns_suffix}"
    library    = "library.${local.magicdns_suffix}"
    postoffice = "postoffice.${local.magicdns_suffix}"
    townhall   = "townhall.${local.magicdns_suffix}"
    shitbox    = "shitbox.${local.magicdns_suffix}"
  }
}
