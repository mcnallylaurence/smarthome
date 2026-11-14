#!/usr/bin/env bash
# Backs up Homebridge + Zigbee2MQTT config and state on the Pi into ~/backups.
# Run as your normal user:  bash scripts/backup-config.sh
# The archive contains SECRETS (Zigbee network key, HomeKit PIN/pairing).
# Keep it private. Never commit it to Git.
set -euo pipefail

STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="$HOME/backups"
OUT="$DEST/smarthome-backup-$STAMP.tar.gz"
mkdir -p "$DEST"
chmod 700 "$DEST"

FILES=(
  /var/lib/homebridge/config.json
  /var/lib/homebridge/persist
  /var/lib/homebridge/accessories
  /opt/zigbee2mqtt/data
  /etc/systemd/system/zigbee2mqtt.service
)

EXISTING=()
for f in "${FILES[@]}"; do
  if sudo test -e "$f"; then EXISTING+=("$f"); else echo "skip (not found): $f"; fi
done

sudo tar -czf "$OUT" "${EXISTING[@]}"
sudo chown "$USER": "$OUT"
chmod 600 "$OUT"

echo "Backup written: $OUT"
echo "Copy it to your Mac, e.g.:"
echo "  scp $USER@$(hostname -I | awk '{print $1}'):$OUT ~/Documents/"
