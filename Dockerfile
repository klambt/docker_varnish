FROM debian:jessie
MAINTAINER Tim Weyand <tim.weyand@klambt.de>

ENV VARNISH_CONFIG  default
ENV VCL_CONFIG      /etc/varnish/default.vcl
ENV CACHE_SIZE      64m
ENV VARNISHD_PARAMS -a :80 -T :6082 -p max_esi_depth=10 -p default_ttl=3600 -p default_grace=3600 -p default_grace=180 -p feature=+esi_disable_xml_check -S /etc/varnish/secret 
ENV UPDATE_DEBIAN   1

COPY  ./scripts/* /usr/local/bin/
ADD ./conf/ /root/varnish-conf/

RUN chmod +x /usr/local/bin/klambt_docker_*.sh \
 && klambt_docker_update_debian.sh \
 && klambt_docker_varnish_install.sh


EXPOSE 80 6082 6081
CMD klambt_docker_varnish_start.sh
