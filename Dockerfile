FROM nginx:stable-alpine
MAINTAINER Chris Wutherich

ENV OVERLAY_VERSION v1.18.1.5
ENV TERM xterm-256color
# Don't start services if cont-init.d fails and shut down container.
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

RUN apk update && apk upgrade
RUN apk add certbot

# Install s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm -R /tmp/s6-overlay-amd64.tar.gz

# root filesystem
COPY rootfs /
# Copy nginx
COPY nginx /etc/nginx

RUN chmod 500 /etc/periodic/monthly/certbot-renew && \
    mkdir /var/log/certbot/ /var/certbot-webroot/ && \
    rm /etc/nginx/conf.d/default.conf

VOLUME ["/etc/letsencrypt"]

ENTRYPOINT [ "/init" ]
CMD ["nginx", "-g", "daemon off;"]
