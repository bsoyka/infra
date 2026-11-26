locals {
  tailnet         = "bensoyka6@gmail.com"
  magicdns_suffix = "broadbill-gecko.ts.net"

  # Devices owned by this tailnet, short name => MagicDNS name. Keyed on the full
  # name rather than hostname -- several devices' hostnames are generic (localhost,
  # ipad, ubuntu) and would be ambiguous or collide with a future device.
  devices = {
    missioncontrol = "missioncontrol.${local.magicdns_suffix}" # MacBook Pro
    pager          = "pager.${local.magicdns_suffix}"          # iPhone
    clipboard      = "clipboard.${local.magicdns_suffix}"      # iPad
    groundstation  = "groundstation.${local.magicdns_suffix}"  # Raspberry Pi
    shitbox        = "shitbox.${local.magicdns_suffix}"        # Dell Latitude
  }
}
