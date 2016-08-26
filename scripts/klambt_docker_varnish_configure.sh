#!/bin/bash

if [ ! -z $DRUPAL_VARNISH_KEY ]; then
    echo $DRUPAL_VARNISH_KEY > /etc/varnish/secret
else
    if [ ! -z $VARNISH_KEY ]; then
        echo $VARNISH_KEY > /etc/varnish/secret
    else
        uuidgen > /etc/varnish/secret
    fi
fi

cp -R /root/varnish-conf/default/* /etc/varnish/
cd /etc/varnish/
grep -rl --include=*.vcl BACKEND_SERVER_ENVIRONMENT ./ | xargs sed -i -e "s/BACKEND_SERVER_ENVIRONMENT/$BACKEND_SERVER/g"

printf "Varnish Secret: ";
cat /etc/varnish/secret