# syntax=docker/dockerfile:1
FROM louislam/uptime-kuma:2

USER root

ARG LITESTREAM_VERSION=0.5.8
# BuildKit setzt TARGETARCH typischerweise auf amd64/arm64
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget tar \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) LS_ARCH="amd64" ;; \
      arm64) LS_ARCH="arm64" ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    wget -nv -O /tmp/litestream.tgz \
      "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-vfs-v${LITESTREAM_VERSION}-linux-${LS_ARCH}.tar.gz"; \
    tar -xzf /tmp/litestream.tgz -C /tmp; \
    install -m 0755 /tmp/litestream /usr/local/bin/litestream; \
    rm -f /tmp/litestream.tgz /tmp/litestream

# Beispiel: du kannst dein litestream.yml auch dynamisch via env erzeugen,
# aber als Startpunkt reicht eine Datei im Image:
COPY litestream.yml /etc/litestream.yml
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 3001
ENV PORT=3001

ENTRYPOINT ["/usr/local/bin/run.sh"]
