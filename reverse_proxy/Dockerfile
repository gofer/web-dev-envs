FROM nginx:alpine

EXPOSE 80
EXPOSE 443

RUN apk update && apk upgrade

RUN mkdir -p /etc/ssl/fake
COPY --chmod=600 ssl/fake_self_signed.pem /etc/ssl/fake/fake_self_signed.pem
COPY --chmod=644 ssl/fake_self_signed.crt /etc/ssl/fake/fake_self_signed.crt

WORKDIR /etc/ssl/certs/user
VOLUME /etc/ssl/certs/user
VOLUME /etc/ssl/private

COPY --chmod=644 --chown=nginx:nginx nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=644 --chown=nginx:nginx nginx/revrse_proxy_params /etc/nginx/revrse_proxy_params
COPY --chmod=644 --chown=nginx:nginx nginx/conf.d/ /etc/nginx/conf.d/

RUN cd / && tar czf /nginx.tar.xz etc/nginx
VOLUME /etc/nginx

WORKDIR /var/www
WORKDIR /var/www/html
COPY --chmod=644 index.html /var/www/html/index.html

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx"]
