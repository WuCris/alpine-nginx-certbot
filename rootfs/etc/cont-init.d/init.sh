#!/usr/bin/with-contenv sh

# This takes all environment variables with DOMAIN_ prefix and prepends a -d flag
# and a www. infront of it (while also preserving non www domains)
DOMAINS=$(env | awk 'BEGIN{FS="="} /DOMAIN_/ {print " -d " $2  " -d www."$2} ORS=" " FS="="')

certbot certonly --webroot -w /var/certbot-webroot/ $DOMAINS
