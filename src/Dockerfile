FROM registry.access.redhat.com/hi/nginx:latest-builder AS builder

FROM registry.access.redhat.com/hi/nginx:latest-fips

ENV IMAGE_ENDPOINT="https://whatever.domain.com/api/image"
ENV BACKGROUND_COLOR="#00aa44"

COPY --from=builder /bin/sh /bin/sh
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY index.html /usr/share/nginx/html/index.html
COPY frame.html /usr/share/nginx/html/frame.html
COPY --chmod=666 config.json /usr/share/nginx/html/config.json

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
