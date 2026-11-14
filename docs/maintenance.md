# Maintenance, backups and to-do list

## Backups (do this after any change)

Run on the Pi:

```
bash scripts/backup-config.sh
```

It saves a dated archive in `~/backups/` containing Homebridge config and HomeKit
pairing data, Zigbee2MQTT config (with the network key), device database and
coordinator backup. Copy the archive to your Mac:

```
scp laurence@192.168.1.15:~/backups/smarthome-backup-*.tar.gz ~/Documents/
```

**Store backups privately** (not in this Git repo, they contain secrets).
Homebridge UI also has its own backup (Settings, Backup, Download).

If you restore a backup onto a new SD card with the same Zigbee dongle, the devices
and HomeKit pairing come back without re-pairing.

## Reboot test (still to do)

```
sudo reboot
```

Wait about 2 minutes, then confirm http://192.168.1.15:8581 and
http://192.168.1.15:8080 both load and Apple Home responds. Both services are
enabled to start at boot (`zigbee2mqtt` via systemd, `homebridge` via the apt
package).

## Updates

- Homebridge and the plugins: from the Homebridge UI (a UI update was waiting).
- Zigbee2MQTT: `cd /opt/zigbee2mqtt && git pull && pnpm install --frozen-lockfile`,
  then `sudo systemctl restart zigbee2mqtt`. Read release notes first, and back up.
- OS: `sudo apt-get update && sudo apt-get full-upgrade` (130+ packages were pending).
- After a Node upgrade, re-run `sudo hb-service update-node 24` and
  `rm -rf node_modules && pnpm install --frozen-lockfile` in Zigbee2MQTT.

## Security checklist

- [ ] Change the SSH password with `passwd` (an earlier one was shared in chat)
- [ ] Make the old GitHub `smarthome` repo **private**; replace its old files with
      these. The old Zigbee network key stays in Git history, so treat it as burned
      (a fresh key was generated on this rebuild)
- [ ] Optional: switch SSH to key login only
- [ ] Zigbee2MQTT UI (:8080) has no password. Keep it on the main LAN only
- [ ] Do not expose ports 8080, 8581 or 1883 to the internet

## To-do list

- [ ] Reserve 192.168.1.15 for the Pi in the Linksys DHCP settings
- [ ] Reboot test (above)
- [ ] Bind the other switches and the remote to the Living Room group (or to their own groups)
- [ ] Rename devices to real locations; fill in the table in `docs/devices.md`
- [ ] Apple Home: rooms, names, check HomePod shown as Connected hub, test Siri
- [ ] Replace the battery in On/off switch 1 (CR2032)
- [ ] Add Home app automations for any buttons not bound in Zigbee
- [ ] TECKIN plug: find the model number, decide the integration
- [ ] Google Nest thermostat (AC): choose the plugin or Google Home route
- [ ] Update Homebridge UI and run OS updates
- [ ] Take a first backup and keep a copy off the Pi

## Ideas if IKEA stays frustrating

- IKEA DIRIGERA hub with Matter, or Matter/Thread devices, can reduce what has to be
  maintained on the Pi. The current setup works, so only change if needed.
