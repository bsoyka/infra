#!/bin/sh
# Wires tailscaled's firewall chains into the kernel's built-in chains, with an
# exception for the printer ahead of them.
#
# Why: the building's LAN is CGNAT space (100.110.x.x), and ts-input drops anything
# from 100.64.0.0/10 that doesn't arrive on tailscale0, so the printer's replies on
# wlan0 were silently dropped. With `tailscale set --netfilter-mode=nodivert`,
# tailscaled still maintains its ts-* chains but leaves the jumps to us.
#
# Install: see README.md in this directory.
set -eu

# The printer's LAN address. If it moves around (no DHCP reservation on the
# building network), widen this to wlan0's subnet, 100.110.197.128/26 -- at the
# cost of trusting every LAN device in that range that claims a tailnet-looking IP.
PRINTER="${PRINTER:-100.110.197.X}"

# Wait for tailscaled to create its chains (up to 30s).
i=0
until iptables -S ts-input >/dev/null 2>&1; do
  i=$((i + 1))
  [ "$i" -ge 30 ] && { echo "ts-input chain never appeared" >&2; exit 1; }
  sleep 1
done

# ensure <cmd> <table> <chain> <position> <rule...>: insert only if missing, so
# re-running (e.g. on every tailscaled restart) is harmless.
ensure() {
  cmd=$1 table=$2 chain=$3 pos=$4
  shift 4
  "$cmd" -t "$table" -C "$chain" "$@" 2>/dev/null ||
    "$cmd" -t "$table" -I "$chain" "$pos" "$@"
}

ensure iptables filter INPUT 1 -s "$PRINTER" -i wlan0 -j ACCEPT
ensure iptables filter INPUT 2 -j ts-input

# The exit node depends on these: forwarding and NAT for clients' traffic.
for cmd in iptables ip6tables; do
  ensure "$cmd" filter FORWARD 1 -j ts-forward
  ensure "$cmd" nat POSTROUTING 1 -j ts-postrouting
done
ensure ip6tables filter INPUT 1 -j ts-input
