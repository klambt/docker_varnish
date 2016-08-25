#!/bin/bash

if [ ! -z $DRUPAL_VARNISH_KEY]; then;
    echo $DRUPAL_VARNISH_KEY > /etc/varnish/secret
else
    if [ ! -z $VARNISH_KEY]; then;
        echo $VARNISH_KEY > /etc/varnish/secret
    else
        uuidgen > /etc/varnish/secret
    fi
fi

cp -R /root/varnish-conf/default/* /etc/varnish/


printf "Varnish Secret: ";
cat /etc/varnish/secret