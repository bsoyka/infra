# bensoyka.net: tools that are just for me (and sometimes a few people I let
# in). Public-facing things stay on bensoyka.com. Every hostname here sits
# behind Cloudflare Access -- see access/ -- so nothing new can go live
# unprotected by accident.
#
# There are no hand-written records yet: the apex (landing page) and
# upload.bensoyka.net are Workers Custom Domains (workers/workers-*.tf), which
# manage their own DNS.

locals {
  # This zone's slice of the curated zone settings (see locals.tf). A new
  # zone with nothing legacy on it, so the TLS core is as strict as it goes.
  bensoyka_net_settings = {
    "bensoyka.net/always_online"            = { zone = "bensoyka.net", setting_id = "always_online", value = "off" }
    "bensoyka.net/always_use_https"         = { zone = "bensoyka.net", setting_id = "always_use_https", value = "on" }
    "bensoyka.net/automatic_https_rewrites" = { zone = "bensoyka.net", setting_id = "automatic_https_rewrites", value = "on" }
    "bensoyka.net/brotli"                   = { zone = "bensoyka.net", setting_id = "brotli", value = "on" }
    "bensoyka.net/browser_check"            = { zone = "bensoyka.net", setting_id = "browser_check", value = "on" }
    "bensoyka.net/challenge_ttl"            = { zone = "bensoyka.net", setting_id = "challenge_ttl", value = 1800 }
    "bensoyka.net/early_hints"              = { zone = "bensoyka.net", setting_id = "early_hints", value = "off" }
    "bensoyka.net/hotlink_protection"       = { zone = "bensoyka.net", setting_id = "hotlink_protection", value = "off" }
    "bensoyka.net/min_tls_version"          = { zone = "bensoyka.net", setting_id = "min_tls_version", value = "1.2" }
    "bensoyka.net/opportunistic_encryption" = { zone = "bensoyka.net", setting_id = "opportunistic_encryption", value = "on" }
    "bensoyka.net/rocket_loader"            = { zone = "bensoyka.net", setting_id = "rocket_loader", value = "off" }
    "bensoyka.net/security_level"           = { zone = "bensoyka.net", setting_id = "security_level", value = "medium" }
    "bensoyka.net/ssl"                      = { zone = "bensoyka.net", setting_id = "ssl", value = "strict" }
    "bensoyka.net/tls_1_3"                  = { zone = "bensoyka.net", setting_id = "tls_1_3", value = "on" }
  }
}
