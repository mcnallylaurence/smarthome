# Troubleshooting log: problems hit so far and fixes

| Symptom | Cause | Fix |
|---|---|---|
| Pi not found on the network; SD card unreadable on Mac | SD card had failed | Replaced card, reflashed (see rebuild guide) |
| Pi not reachable after moving cables | Cable/port confusion between modem, Linksys and the Netgear switch | Plug the Pi into the Linksys router (192.168.1.x). The SB8200 is only a modem. |
| `corepack: command not found` | Node 26 install does not bundle corepack | `sudo npm install -g corepack && sudo corepack enable` (later moved to Node 24) |
| Zigbee2MQTT "unsupported engine" warning on Node 26 | Node 26 is not supported by Z2M | Install Node 24 (NodeSource `setup_24.x`) |
| `NODE_MODULE_VERSION 147 vs 137` native module error | `node_modules` built for a different Node version | `cd /opt/zigbee2mqtt && rm -rf node_modules && pnpm install --frozen-lockfile` |
| `Cannot lock port` | A second Zigbee2MQTT instance already holds the dongle | `ps aux \| grep zigbee`, stop the extra one (`sudo systemctl stop zigbee2mqtt` or kill it), start once |
| Z2M page on :8080 says connection refused | Frontend disabled in config | In `/opt/zigbee2mqtt/data/configuration.yaml` set `frontend: enabled: true`, port 8080; restart |
| `systemctl status zigbee2mqtt` stuck on "activating (start)" | Same native module error | Fix as above, then restart |
| No devices in Homebridge Accessories | Two causes: (1) Homebridge's own Node was v26, plugin needs 20/22/24; (2) invalid empty `devices` entry in the plugin config | `sudo hb-service update-node 24`; make the plugin block just platform + mqtt (see rebuild guide step 7); restart |
| Plugin log says `INVALID CONFIGURATION FOR PLUGIN: homebridge-z2m` | Empty or malformed entry in `devices` | Remove the `devices` list entirely; keep JSON valid (one plugin block, no pasted blocks inside another) |
| In the Bind tab the Destination box was greyed out | It is an existing default row; also the page can lose its connection | Use **+ Add** for a new row, refresh the page |
| New binding to the plug showed no clusters | Plug as a direct destination showed nothing | Create a Zigbee group containing the plug and bind the switch to the group |
| Switch pressed, plug does nothing | Switch asleep when bound, or bind not applied | Wake switch (press a button), Unbind then Bind again; check Logs for the press |
| Battery tiles in Home show 0% "Not Chargeable" | Plugin has no reading yet | Press a button / wait; check real % in Zigbee2MQTT |

## Useful commands (on the Pi)

```
systemctl status zigbee2mqtt          # is Zigbee2MQTT running
journalctl -u zigbee2mqtt -n 100 --no-pager   # its recent log
sudo systemctl restart zigbee2mqtt
sudo hb-service status                # Homebridge
sudo hb-service restart
sudo hb-service logs                  # follow Homebridge log
ls -l /dev/serial/by-id/              # is the dongle seen
lsusb                                 # dongle shows as Silicon Labs CP210x
mosquitto_sub -h localhost -t 'zigbee2mqtt/#' -v   # watch MQTT messages (Ctrl+C to stop)
node -v; /opt/homebridge/bin/node -v  # system Node and Homebridge's Node
```

## Lessons learned

- Always check the **program's own** supported Node range. Do not install the
  newest Node blindly; use Node 24 LTS-line releases for this stack.
- Two copies of Node exist (system and Homebridge's). Fix both.
- Do not paste secrets (passwords, network key, HomeKit PIN) into chats or repos.
- Make small config changes and restart one service at a time.
