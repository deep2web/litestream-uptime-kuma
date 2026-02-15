# syntax=docker/dockerfile:1
FROM louislam/uptime-kuma:2

USER root

# Litestream v0.3.13 (stabil)
ARG LITESTREAM_VERSION=0.3.13

# Installiere Tools
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget tar \
    && rm -rf /var/lib/apt/lists/*

# Litestream installieren
RUN wget -nv -O /tmp/litestream.tar.gz \
      "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-amd64.tar.gz" \
    && tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz \
    && rm /tmp/litestream.tar.gz

# WICHTIG für Kuma v2: db-config.json vorerstellen
# Damit weiß Kuma sofort: "Ich bin SQLite" und überspringt das Setup
RUN echo '{\n\
  "type": "sqlite",\n\
  "hostname": "127.0.0.1",\n\
  "port": 3306,\n\
  "user": "uptime-kuma",\n\
  "password": "",\n\
  "database": "uptime-kuma",\n\
  "dbPath": "./data/kuma.db"\n\
}' > /app/db-config.json

COPY litestream.yml /etc/litestream.yml
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 3001
ENV PORT=3001

ENTRYPOINT ["/usr/local/bin/run.sh"]
