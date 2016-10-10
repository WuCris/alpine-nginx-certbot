#!/usr/bin/with-contenv sh

set -e

# If TOS isn't agreed to output error to stderr
if [ ! $AGREE_TO_TOS = yes ]; then
  echo "FAILURE: Let's Encrypt Terms of Service hasn't been agreed to. EXITING..." 1>&2
  s6-svscanctl -t /var/run/s6/services
fi

# If email not set output error to stderr
if [ -z $EMAIL_ACCOUNT ]; then
  echo "FAILURE: Email for Let's Encypt not set. EXITING..." 1>&2
  s6-svscanctl -t /var/run/s6/services
fi


# This takes all environment variables with DOMAIN_ prefix and prepends a -d flag
# and a www. infront of it (while also preserving non www domains)
DOMAINS=$(env | awk 'BEGIN{FS="="} /DOMAIN_/ {print " -d " $2  " -d www."$2} ORS=" " FS="="')

certbot certonly --agree-tos --account $EMAIL_ACCOUNT --webroot -w /var/certbot-webroot/ $DOMAINS
