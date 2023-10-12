FROM alpine:latest AS configure-building

ARG ipv4_internal_iprange
ARG ipv4_nsd_internal_addr
ENV IPV4_INTERNAL_IPRANGE="${ipv4_internal_iprange}"
ENV IPV4_NSD_INTERNAL_ADDR="${ipv4_nsd_internal_addr}"

WORKDIR /tmp

COPY ./zones /tmp/zones
COPY ./nsd/nsd.conf.in /tmp/nsd.conf.in
COPY ./nsd/generator.py /tmp/generator.py

RUN apk update && apk upgrade \
 && apk add python3

RUN python3 -m ensurepip \
 && pip3 install jinja2 \
 && chmod +x /tmp/generator.py \
 && python3 /tmp/generator.py

FROM alpine:latest

RUN apk update && apk upgrade

COPY --from=configure-building /tmp/nsd.conf /etc/nsd/nsd.conf
COPY ./zones /etc/nsd/zones

RUN apk update && apk upgrade \
 && apk add openssl nsd

RUN chmod 644 /etc/nsd/nsd.conf \
 && chown -R nsd:nsd /etc/nsd \
 && mkdir -p /run/nsd && chown -R nsd:nsd /run/nsd \
 && nsd-control-setup \
 && nsd-checkconf /etc/nsd/nsd.conf

CMD nsd-control start && tail -f /dev/null
