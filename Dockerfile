FROM million12/varnish
MAINTAINER Tim Weyand <tim.weyand@klambt.de>

COPY ./conf/default/defaul.vcl /etc/varnish/default.vcl