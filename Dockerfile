FROM million12/varnish
MAINTAINER Tim Weyand <tim.weyand@klambt.de>

COPY ./scripts/* /usr/local/bin/
COPY ./conf/* /root/varnish-conf/

RUN chmod +x /usr/local/bin/klambt_docker_*.sh

CMD klambt_docker_varnish_start.sh
