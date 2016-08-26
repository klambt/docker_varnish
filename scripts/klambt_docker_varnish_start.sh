#!/bin/bash

klambt_docker_varnish_configure.sh

set -e

exec bash -c \
  "exec varnishd -F \
  -f $VCL_CONFIG \
  -s malloc,$CACHE_SIZE \
  $VARNISHD_PARAMS"