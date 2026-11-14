# Devices, pairing, groups and bindings

## Inventory (Zigbee, paired to Zigbee2MQTT)

| Name in Zigbee2MQTT | Product | Role |
|---|---|---|
| Living Room Light (was "Living Room 1") | IKEA TRÅDFRI control outlet (E1603 / E1702 / E1708) | Plug, also acts as a Zigbee router |
| On/off switch 0 | IKEA TRÅDFRI on/off switch (E1743) | Button, battery CR2032 |
| On/off switch 1 | IKEA TRÅDFRI on/off switch (E1743) | Button, battery was about 16% (replace) |
| On/off switch 2 | IKEA TRÅDFRI on/off switch (E1743) | Button |
| Remote control 1 | IKEA STYRBAR remote (E2001 / E2002 / E2313), white | Remote, battery powered |

Rename each switch to where it physically is (for example "Bedroom switch"): press
the button and watch the Logs tab or the Dashboard in Zigbee2MQTT to see which one
reacts, then rename it in its Settings tab. Add the real locations here:

| Device | Physical location / what it controls |
|---|---|
| On/off switch 0 | (fill in) controls Living Room group |
| On/off switch 1 | (fill in) |
| On/off switch 2 | (fill in) |
| Remote control 1 | (fill in) |

## Not yet integrated

- **TECKIN plug:** probably Wi-Fi / Tuya, not Zigbee. Model number needed. Likely
  options are a Homebridge Tuya plugin, or Apple Home directly if it is a HomeKit
  or Matter model.
- **Google Nest thermostat (AC):** needs a separate Homebridge plugin (Google Nest
  / Device Access setup) or Google Home integration.

## Pairing (joining) devices

In Zigbee2MQTT press **Permit join (All)** first (it times out after a few minutes).

| Device | How to put it in pairing mode |
|---|---|
| TRÅDFRI control outlet (E1603/E1702/E1708) | Press a paperclip into the reset pinhole until the light fades, then it connects by itself |
| TRÅDFRI on/off switch (E1743) | Open the back cover (CR2032) and press the pair button 4 times |
| STYRBAR remote (E2001/E2002/E2313) | Press the pair button 4 times, near the coordinator |

Battery devices must be awake: press a button on them right before a bind,
reconfigure or other command.

## Groups

| Group | Members | Purpose |
|---|---|---|
| Living Room | Living Room Light (endpoint 1) | Target for switch bindings |
| default_bind_group | built in | Zigbee2MQTT default; ignore |

## Bindings (direct switch to plug, works without the Pi or HomePod)

| Source | Destination | Cluster |
|---|---|---|
| On/off switch 0 | Living Room (group) | genOnOff |

Every battery switch also keeps a binding to the **Coordinator** (genOnOff,
genLevelCtrl, genPowerCfg). That is how Zigbee2MQTT sees button presses. **Never use
"Clear all"** in the Bind tab, because it removes that.

### How to add a binding

1. Zigbee2MQTT, Devices, click the switch, Bind tab.
2. Click **+ Add**, Destination = the group (for example Living Room).
   (Binding straight to the plug showed an empty cluster list, so bind to a group.)
3. Cluster `genOnOff` ticked.
4. Press a button on the switch to wake it, then click **Bind** straight away.
5. Test the on and off buttons. If nothing happens, press again, or Unbind then Bind
   again with the switch awake. Check the Logs tab to see whether the press arrives.

## How the buttons look in Apple Home

homebridge-z2m shows each button action as its own tile ("On off switch 0 on",
"... off", "... brightness up", and so on), all "Stateless Programmable Switch".
Battery tiles reading 0% / "Not Chargeable" are usually just a reading the plugin
has not received yet. Check the real level in Zigbee2MQTT.
