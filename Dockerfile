# syntax=docker/dockerfile:1
FROM louislam/uptime-kuma:2

USER root

# Wir nutzen v0.3.13 - sehr stabil und weit verbreitet
ARG LITESTREAM_VERSION=0.3.13

# Installiere wget und tar
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget tar \
    && rm -rf /var/lib/apt/lists/*

# Lade Litestream herunter (OHNE "-static" im Namen!)
RUN wget -nv -O /tmp/litestream.tar.gz \
      "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-amd64.tar.gz" \
    && tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz \
    && rm /tmp/litestream.tar.gz

# Verifiziere Installation
RUN litestream version

# Kopiere Config und Startskript
COPY litestream.yml /etc/litestream.yml
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 3001
ENV PORT=3001

ENTRYPOINT ["/usr/local/bin/run.sh"]
