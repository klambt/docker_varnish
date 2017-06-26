#!/bin/bash

curl -fsSL https://repo.varnish-cache.org/GPG-key.txt | apt-key add - 
echo "deb https://repo.varnish-cache.org/debian/ xenial varnish-4.1" >> /etc/apt/sources.list.d/varnish-cache.list
apt-get update
apt-get install --no-install-recommends -qy varnish

###
# Cleanup Apt
###
apt-get autoclean 
apt-get clean 
rm -rf /var/cache/apt/* 
truncate --size 0 /var/log/*.log
rm -rf /var/lib/apt/lists/*


cp /root/varnish-conf/varnish/varnish.cfg /etc/default/varnish