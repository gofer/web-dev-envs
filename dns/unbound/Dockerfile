FROM alpine:latest AS configure-building

ARG ipv4_internal_iprange
ARG ipv4_unbound_internal_addr
ARG ipv4_nsd_internal_addr
ARG dns_primary
ARG dns_secondary

ENV IPV4_INTERNAL_IPRANGE="${ipv4_internal_iprange}"
ENV IPV4_UNBOUND_INTERNAL_ADDR="${ipv4_unbound_internal_addr}"
ENV IPV4_NSD_INTERNAL_ADDR="${ipv4_nsd_internal_addr}"
ENV DNS_PRIMARY="${dns_primary}"
ENV DNS_SECONDARY="${dns_secondary}"

WORKDIR /tmp

COPY ./zones /tmp/zones
COPY ./unbound/unbound.conf.in /tmp/unbound.conf.in
COPY ./unbound/generator.py /tmp/generator.py

RUN apk update && apk upgrade \
 && apk add python3

RUN python3 -m ensurepip \
 && pip3 install jinja2 \
 && chmod +x /tmp/generator.py \
 && python3 /tmp/generator.py

FROM alpine:latest

COPY --from=configure-building /tmp/unbound.conf /etc/unbound/unbound.conf

RUN apk update && apk upgrade \
 && apk add openssl unbound

RUN chmod 644 /etc/unbound/unbound.conf \
 && chown -R unbound:unbound /etc/unbound \
 && unbound-control-setup \
 && unbound-checkconf /etc/unbound/unbound.conf

CMD unbound-control start && tail -f /dev/null
