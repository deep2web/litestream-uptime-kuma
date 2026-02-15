#!/bin/sh
set -eu

echo "==> Starting Litestream + Uptime Kuma"

# Erstelle Data-Verzeichnis
mkdir -p /app/data

# Restore DB von S3, falls vorhanden
echo "==> Attempting to restore database from replica..."
litestream restore -if-replica-exists -config /etc/litestream.yml /app/data/kuma.db || true

# Starte Litestream im Hintergrund für continuous replication
echo "==> Starting Litestream replication..."
litestream replicate -config /etc/litestream.yml &

# Warte kurz, damit Litestream ready ist
sleep 2

# Starte Uptime Kuma (im Foreground, damit Container nicht beendet)
echo "==> Starting Uptime Kuma..."
exec node server/server.js
