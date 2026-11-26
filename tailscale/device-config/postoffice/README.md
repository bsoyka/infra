# postoffice: device-side firewall setup

Lets postoffice (the exit node) reach the printer on the building's CGNAT LAN
while staying on the tailnet. See the comments in `ts-jumps.sh` for why.

Set the printer's address and interface in `ts-jumps.service` first (`PRINTER=`, `IFACE=`), then on postoffice:

```sh
sudo install -m 755 ts-jumps.sh /usr/local/sbin/ts-jumps
sudo install -m 644 ts-jumps.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo tailscale set --netfilter-mode=nodivert   # exit node NAT is off until the next line
sudo systemctl enable --now ts-jumps
```

Check:

```sh
sudo iptables -S INPUT | head -3      # printer ACCEPT, then -j ts-input
sudo iptables -t nat -S POSTROUTING   # includes -j ts-postrouting
ping -c 3 <printer address>
```

Then test the exit node from another device. Over SSH via Tailscale, run the install inside `tmux`; the session should survive (the `INPUT` policy is `ACCEPT`), but a dropped connection shouldn't leave it half done. To undo: `sudo systemctl disable --now ts-jumps`
and `sudo tailscale set --netfilter-mode=on`.
