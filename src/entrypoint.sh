#!/bin/sh
set -e

if [ -z "$IMAGE_ENDPOINT" ]; then
    echo "ERROR: IMAGE_ENDPOINT is required" && exit 1
elif [ -z "$BACKGROUND_COLOR" ]; then
    echo "ERROR: BACKGROUND_COLOR is required" && exit 1
fi

printf '{\n  "imageEndpoint": "%s",\n  "backgroundColor": "%s"\n}\n' \
    "$IMAGE_ENDPOINT" "$BACKGROUND_COLOR" \
    > /usr/share/nginx/html/config.json

exec nginx -g 'daemon off;'
