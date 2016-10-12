#!/usr/bin/with-contenv sh

TOS=0
EMAIL=0

# If TOS isn't agreed to output error to stderr
if [ ! "$AGREE_TO_TOS" = "yes" ]; then   TOS=1; fi
# If email not set output error to stderr
if [ -z $EMAIL_ACCOUNT ]; then   EMAIL=2; fi

SUM=$(($TOS+$EMAIL))

TOS_ERROR=$(echo "ERROR: Let's Encrypt Terms of Service hasn't been agreed to. EXITING...")
EMAIL_ERROR=$(echo "ERROR: Email for Let's Encypt not set. EXITING...")

case "$SUM" in
        0)
            s6-echo "TOS and Email agreed to, continuing..."
            ;;
        1)
            echo "$TOS_ERROR" 1>&2
            ;;
        2)
            echo "$EMAIL_ERROR" 1>&2
            ;;
        3)
            echo "$TOS_ERROR" 1>&2
            echo "$EMAIL_ERROR" 1>&2
            ;;
esac

if [ $SUM -gt 0 ]; then
    redirfd -w 1 /var/run/s6/env-stage3/S6_CMD_EXITED s6-echo -n -- "13$SUM"
    s6-svscanctl -t /var/run/s6/services
    exit "13$SUM"
fi


exit_on_certbot_fail ()
{
    EXIT_STATUS=$?
    redirfd -w 1 /var/run/s6/env-stage3/S6_CMD_EXITED s6-echo -n -- "$EXIT_STATUS"
    s6-svscanctl -t /var/run/s6/services
    exit  "$EXIT_STATUS"
}

# This takes all environment variables with DOMAIN_ prefix and prepends a -d flag
# and a www. infront of it (while also preserving non www domains)
DOMAINS=$(env | awk 'BEGIN{FS="="} /DOMAIN_/ {print " -d " $2  " -d www."$2} ORS=" " FS="="')
certbot certonly --agree-tos --account $EMAIL_ACCOUNT --webroot -w /var/certbot-webroot/ $DOMAINS || exit_on_certbot_fail
