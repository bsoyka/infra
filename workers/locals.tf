locals {
  account_id = "c13c82492d318fee88e1d77400282706"

  # Zone IDs for the zones that have Workers Custom Domains attached. Kept in
  # sync by hand with dns/locals.tf -- no shared module exists between the two
  # root modules, and it's not worth one for three lines of data.
  zone_ids = {
    "bensoyka.com"                              = "c0e27eb0bfcc5e664c3bc8f3019167ad"
    "bsoyka.me"                                 = "8c2a35e47279bf4b28daaec46b569b57"
    "howlonghasthehubbeenunderconstruction.com" = "9a20cb9814d9dffbdfe93e4c5f9e99e1"
  }
}
