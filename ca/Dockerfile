FROM alpine:latest

ARG root_ca_dir

EXPOSE 80
EXPOSE 2560
EXPOSE 2561

RUN apk update && apk upgrade \
 && apk add openssl nginx

RUN openssl rand -writerand /root/.rnd

RUN cp /etc/ssl/openssl.cnf /etc/ssl/openssl.orginal.cnf
COPY --chmod=644 resource/ssl/openssl.cnf /etc/ssl/openssl.cnf

COPY resource/script/ /usr/local/bin/

RUN rm -rf /etc/nginx/*
COPY --chmod=644 --chown=nginx:nginx resource/nginx /etc/nginx

RUN mkdir -p /var/www/ca

RUN ln -s /dev/stdout /var/log/nginx/access.log \
 && ln -s /dev/stderr /var/log/nginx/error.log

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx"]
