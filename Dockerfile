FROM nginx:stable-alpine
MAINTAINER Chris Wutherich

##
## ROOTFS
##
ENV OVERLAY_VERSION v1.18.1.5

RUN apk update
RUN apk upgrade

RUN apk add certbot

# root filesystem
COPY rootfs /

# Install s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm -R /tmp/s6-overlay-amd64.tar.gz

RUN chmod 500 /etc/periodic/monthly/certbot-renew
RUN mkdir /var/log/certbot/

VOLUME ["/etc/letsencrypt"]

ENTRYPOINT [ "/init" ]
CMD ["nginx", "-g", "daemon off;"]
