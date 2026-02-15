#!/bin/sh
set -eu

# Beispiel: DB liegt bei Uptime-Kuma typischerweise in /app/data
mkdir -p /app/data

# Restore (falls Replica vorhanden), danach Kuma starten
litestream restore -if-replica-exists -config /etc/litestream.yml /app/data/kuma.db || true

exec node server/server.js
