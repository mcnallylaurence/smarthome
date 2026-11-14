#!/usr/bin/env bash
# Installs Mosquitto, Node 24, Zigbee2MQTT and its systemd service on the Pi.
# Replaces the old z2m.sh. Run as your normal user (NOT root):  bash scripts/install-zigbee2mqtt.sh
# Prerequisite: the Sonoff dongle is plugged in (check: ls -l /dev/serial/by-id/).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not root." >&2
  exit 1
fi

echo "==> Packages and Mosquitto (MQTT broker)"
sudo apt-get update
sudo apt-get install -y mosquitto mosquitto-clients git make g++ gcc libsystemd-dev curl
sudo systemctl enable --now mosquitto

echo "==> Node.js 24 (NodeSource)"
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v

echo "==> corepack / pnpm"
sudo npm install -g corepack
sudo corepack enable

echo "==> Zigbee2MQTT into /opt/zigbee2mqtt"
sudo mkdir -p /opt/zigbee2mqtt
sudo chown -R "$USER": /opt/zigbee2mqtt
if [ ! -d /opt/zigbee2mqtt/.git ]; then
  git clone --depth 1 https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
fi
cd /opt/zigbee2mqtt
pnpm install --frozen-lockfile

echo "==> systemd service"
sudo cp "$SCRIPT_DIR/../config/zigbee2mqtt.service" /etc/systemd/system/zigbee2mqtt.service
sudo sed -i "s/^User=.*/User=$USER/" /etc/systemd/system/zigbee2mqtt.service
sudo systemctl daemon-reload
sudo systemctl enable zigbee2mqtt.service

cat <<'EOF'

Done installing. Next:
  1. First run for the onboarding wizard:  cd /opt/zigbee2mqtt && pnpm start
     then open http://<pi-ip>:8080, use the by-id serial path, adapter zstack,
     MQTT mqtt://localhost:1883, and let it generate a NEW network key.
  2. Stop it (Ctrl+C), then:  sudo systemctl start zigbee2mqtt
  3. Check:  systemctl status zigbee2mqtt
See docs/rebuild-guide.md for the remaining steps (Homebridge plugin etc).
EOF
