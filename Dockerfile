FROM alpine:3.4
MAINTAINER Chris Wutherich

##
## ROOTFS
##

RUN apk update
RUN apk upgrade

RUN apk add nginx
RUN apk add certbot

# root filesystem
COPY rootfs /

# s6 overlay
RUN apk add --no-cache ca-certificates wget \
 && wget https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.3/s6-overlay-amd64.tar.gz -O /tmp/s6-overlay.tar.gz \
 && tar xvfz /tmp/s6-overlay.tar.gz -C / \
 && rm -f /tmp/s6-overlay.tar.gz \
 && apk del wget ca-certificates

RUN mkdir /run/nginx

VOLUME ["/etc/letsencrypt"]

ENTRYPOINT [ "/init" ]
CMD ["nginx", "-g", "daemon off;"]
