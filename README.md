# Home smart-home: Homebridge + Zigbee2MQTT on a Raspberry Pi

Last rebuilt: **13 Nov 2026** (fresh SD card after the original card died).

> **Keep this repo PRIVATE.** It documents the home network. Never commit the Zigbee
> network key, the Homebridge setup PIN, passwords, or backups (see `.gitignore`).

## What this does

IKEA Zigbee plugs, switches and remotes are controlled through Apple Home / Siri.
The HomePod is the Apple Home hub. Switches can also control plugs directly over
Zigbee (bindings), so they keep working if the Pi or Wi-Fi is down.

```
IKEA devices ──Zigbee──> Sonoff USB dongle ──> Zigbee2MQTT ──MQTT──> Mosquitto
                                                                        │
Apple Home / Siri / HomePod  <──HomeKit──  Homebridge + homebridge-z2m ─┘
```

## Hardware

| Item | Detail |
|---|---|
| Computer | Raspberry Pi 4 Model B, wired Ethernet to the Linksys router |
| Zigbee radio | Sonoff Zigbee 3.0 USB Dongle Plus (CC2652P, "-P" model), adapter `zstack` |
| Dongle port | Black USB 2.0 port (ideally on a short USB extension cable) |
| Storage | microSD card (replaced Nov 2026; the old one failed) |
| Hub | Apple HomePod |

## Software and versions (as of Nov 2026)

| Component | Version | Notes |
|---|---|---|
| OS | Raspberry Pi OS Lite 64-bit (Debian 13 "Trixie") | hostname `homebridge`, user `laurence`, SSH on |
| Homebridge | 2.5.0 | installed from the official apt repo |
| Homebridge UI | 5.30.0 | port 8581 |
| homebridge-z2m plugin | 1.11.0 | exposes Zigbee2MQTT devices to HomeKit |
| Zigbee2MQTT | 2.14.3 | `/opt/zigbee2mqtt`, runs as a systemd service |
| Node.js (system, for Z2M) | 24.22.3 | NodeSource `node_24.x` |
| Node.js (Homebridge's own copy) | 24.22.3 | `/opt/homebridge/bin`, updated with `sudo hb-service update-node 24` |
| Mosquitto (MQTT broker) | apt package | localhost only |

**Important:** Homebridge uses its *own* Node, separate from the system Node.
homebridge-z2m needs Node 20, 22 or 24. Node 26 does not work for either piece.

## Addresses and ports

| What | Where |
|---|---|
| Pi | `192.168.1.15` (reserve this in the Linksys DHCP settings) |
| Homebridge UI | http://192.168.1.15:8581 |
| Zigbee2MQTT UI | http://192.168.1.15:8080 (no login, keep it LAN only) |
| MQTT | `localhost:1883`, base topic `zigbee2mqtt` |
| Homebridge HomeKit bridge | name "Homebridge 94D6", port 51376 |

Use the main Wi-Fi/LAN (not the guest network) so Apple Home can reach the Pi.

## Repo layout

```
README.md                  this file
docs/rebuild-guide.md      step-by-step rebuild from a blank SD card
docs/devices.md            device inventory, pairing methods, bindings, groups
docs/troubleshooting.md    every problem hit so far and its fix
docs/maintenance.md        backups, reboot test, security checklist, to-do list
config/homebridge-config.sanitized.json   Homebridge config (PIN removed)
config/zigbee2mqtt-settings-reference.yaml  key Z2M settings (no secrets)
config/zigbee2mqtt.service                systemd unit for Zigbee2MQTT
scripts/install-zigbee2mqtt.sh            installs Mosquitto, Node 24, Z2M, service
scripts/backup-config.sh                  backs up all config on the Pi
.gitignore                                keeps secrets out of Git
```

## Where the real (secret) files live on the Pi

| File | Contains |
|---|---|
| `/var/lib/homebridge/config.json` | Homebridge config including the HomeKit PIN |
| `/var/lib/homebridge/persist/` | HomeKit pairing data (lose it = re-add the bridge in Apple Home) |
| `/opt/zigbee2mqtt/data/configuration.yaml` | Zigbee network key and settings |
| `/opt/zigbee2mqtt/data/database.db` | list of paired Zigbee devices |
| `/opt/zigbee2mqtt/data/coordinator_backup.json` | Zigbee network backup |

The Zigbee network key lets someone control or join your Zigbee devices. The key in
the old `smarthome` repo was published and has been replaced by a fresh one. Do not
reuse it.

## Still to do

See `docs/maintenance.md`.
