# groundstation: device-side firewall setup

Lets groundstation (the exit node) reach the printer on the building's CGNAT LAN
while staying on the tailnet. See the comments in `ts-jumps.sh` for why.

The printer (HP DeskJet 2800, `printer.local`) is on the Wi-Fi side of the building
network, reached over `wlan0` -- so groundstation needs Wi-Fi up even though it uses Ethernet
otherwise. Nothing here pins the printer's address; CUPS finds it by name. On groundstation:

```sh
sudo install -m 755 ts-jumps.sh /usr/local/sbin/ts-jumps
sudo install -m 644 ts-jumps.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo tailscale set --netfilter-mode=nodivert   # exit node NAT is off until the next line
sudo systemctl enable --now ts-jumps
```

Check:

```sh
sudo iptables -S INPUT | head -4      # two wlan0 ACCEPTs, then -j ts-input
sudo iptables -t nat -S POSTROUTING   # includes -j ts-postrouting
avahi-resolve -n printer.local       # resolves to the printer's current address
```

Then test the exit node from another device. Over SSH via Tailscale, run the install inside `tmux`; the session should survive (the `INPUT` policy is `ACCEPT`), but a dropped connection shouldn't leave it half done. To undo: `sudo systemctl disable --now ts-jumps`
and `sudo tailscale set --netfilter-mode=on`.

## CUPS

The printer is shared to the tailnet as the `paperjam` queue. CUPS rejects requests
addressed to names it doesn't know (`400 Bad Request`), so `/etc/cups/cupsd.conf` needs:

```
ServerAlias groundstation groundstation.broadbill-gecko.ts.net
```

Clients add `ipp://groundstation.broadbill-gecko.ts.net/printers/paperjam` with `-m everywhere`.
Discovery over mDNS doesn't cross Tailscale, so iOS devices can't add it.
