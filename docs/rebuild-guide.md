# Rebuild guide (blank SD card to working smart home)

Follow in order. About 60 to 90 minutes. Pi 4 Model B, Ethernet, Sonoff dongle.

## 1. Flash the SD card (on the Mac)

1. Install **Raspberry Pi Imager**.
2. Device: Raspberry Pi 4. OS: **Raspberry Pi OS Lite (64-bit)**.
3. In the settings screens:
   - Hostname: `homebridge`
   - Username: `laurence`, with a **strong** password (not a word, not shared in chat)
   - Enable **SSH** (password authentication)
   - Wi-Fi is optional, Ethernet is used
4. Write the card, put it in the Pi, plug in Ethernet and power.

## 2. Find and log in to the Pi

The Pi has been at `192.168.1.15`. If unsure, check the router's device list, or:

```
ssh laurence@homebridge.local
# or
ssh laurence@192.168.1.15
```

If SSH complains about a changed host key after a rebuild:
`ssh-keygen -R 192.168.1.15` then try again.

Then update and set a strong password if you have not:

```
sudo apt-get update && sudo apt-get full-upgrade -y
passwd
```

## 3. Install Homebridge (official apt repo)

```
curl -sSfL https://repo.homebridge.io/KEY.gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/homebridge.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/homebridge.gpg] https://repo.homebridge.io stable main" | sudo tee /etc/apt/sources.list.d/homebridge.list > /dev/null
sudo apt-get update
sudo apt-get install -y homebridge
```

Open http://192.168.1.15:8581, create the admin user, and pair the bridge:

- Apple Home app, Add Accessory, scan the QR code on the Homebridge Status page (or
  enter the PIN shown there).
- Name the bridge when asked. The bridge shows as "Homebridge 94D6".

## 4. Plug in the Zigbee dongle and check it

Plug the Sonoff dongle into a **black USB 2.0 port** (use an extension cable if
possible), then reboot (`sudo reboot`), SSH back in and check:

```
ls -l /dev/serial/by-id/
```

You should see a path like
`usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_<serial>-if00-port0` pointing to
`ttyUSB0`. Use this by-id path in the Zigbee2MQTT settings; it is more stable than
`/dev/ttyUSB0`.

## 5. Install Mosquitto, Node 24 and Zigbee2MQTT

From this repo, on the Pi:

```
bash scripts/install-zigbee2mqtt.sh
```

It installs Mosquitto, Node 24, pnpm via corepack, clones Zigbee2MQTT into
`/opt/zigbee2mqtt`, installs dependencies and creates the systemd service. Details
and the manual commands are inside the script.

First start (for the onboarding wizard):

```
cd /opt/zigbee2mqtt
pnpm start
```

Open http://192.168.1.15:8080 and complete onboarding. Use these settings:

- MQTT server: `mqtt://localhost:1883`, base topic `zigbee2mqtt`
- Serial port: the `/dev/serial/by-id/...` path from step 4
- Adapter: `zstack` (CC2652P)
- Let it generate a **new network key**. Never reuse an old or published one.
- Frontend enabled, port 8080

Stop it with Ctrl+C, then run it as a service:

```
sudo systemctl enable --now zigbee2mqtt
systemctl status zigbee2mqtt
```

If the web page does not load, make sure the frontend is on in
`/opt/zigbee2mqtt/data/configuration.yaml`:

```
frontend:
  enabled: true
  port: 8080
```

Then `sudo systemctl restart zigbee2mqtt`.

## 6. Put Homebridge on Node 24

Homebridge ships its own Node. If it is not 20, 22 or 24, run:

```
sudo hb-service update-node 24
sudo hb-service restart
```

## 7. Install and configure homebridge-z2m

1. In the Homebridge UI, Plugins, search `homebridge-z2m`, install.
2. Open Config (JSON) and make the plugin block exactly this (nothing else inside):

```
{
    "platform": "zigbee2mqtt",
    "mqtt": {
        "base_topic": "zigbee2mqtt",
        "server": "mqtt://localhost:1883"
    }
}
```

   Do **not** leave an empty entry in a `devices` list. It makes the plugin refuse to
   start ("Incorrect configuration: Entry for device is not correct").
   See `config/homebridge-config.sanitized.json` for the whole file.
3. Save, restart Homebridge, check the Logs tab for `[zigbee2mqtt]` lines finding
   devices, and the Accessories tab for your devices.

## 8. Pair the Zigbee devices

See `docs/devices.md` for the reset steps for each device type. In the Zigbee2MQTT
UI press **Permit join (All)** first, then reset the device.

## 9. Finish in Apple Home

- Devices appear under the "Homebridge 94D6" bridge. Rename them and assign rooms.
- Confirm Home Settings, Home Hubs & Bridges shows the HomePod as Connected.
- Test: "Hey Siri, turn off the living room light."
- For remotes and buttons (they show as "Stateless Programmable Switch"), either bind
  them to plugs in Zigbee2MQTT (preferred, see `docs/devices.md`) or make Home app
  automations ("An Accessory is Controlled").

## 10. Reboot test

```
sudo reboot
```

After about 2 minutes, both http://192.168.1.15:8581 and http://192.168.1.15:8080
should load without you doing anything, and the plug should respond in Apple Home.
