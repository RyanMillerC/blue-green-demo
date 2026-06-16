#!/bin/sh
set -e

if [ -z "$IMAGE_ENDPOINT" ]; then
    echo "ERROR: IMAGE_ENDPOINT is required" && exit 1
elif [ -z "$BACKGROUND_COLOR" ]; then
    echo "ERROR: BACKGROUND_COLOR is required" && exit 1
fi

cat > /usr/share/nginx/html/config.json <<EOF
{
  "imageEndpoint": "${IMAGE_ENDPOINT}",
  "backgroundColor": "${BACKGROUND_COLOR}"
}
EOF

exec nginx -g 'daemon off;'
