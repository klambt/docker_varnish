#!/bin/bash

apt-get install curl wget apt-transport-https  -y
curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add -
echo "deb https://repo.varnish-cache.org/debian/ jessie varnish-4.1" \
    >> /etc/apt/sources.list.d/varnish-cache.list
apt-get update
apt-get install varnish -y

cp /root/varnish-conf/varnish/varnish.cfg /etc/default/varnish