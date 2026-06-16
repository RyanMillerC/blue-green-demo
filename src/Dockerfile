FROM nginx:alpine

ENV IMAGE_ENDPOINT="https://whatever.domain.com/api/image"
ENV BACKGROUND_COLOR="#00aa44"

COPY index.html /usr/share/nginx/html/index.html
COPY frame.html /usr/share/nginx/html/frame.html
COPY config.json /usr/share/nginx/html/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
