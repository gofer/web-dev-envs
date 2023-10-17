FROM nginx:alpine

EXPOSE 80
EXPOSE 443

RUN apk update && apk upgrade

RUN mkdir -p /etc/ssl/fake
COPY ssl/fake_self_signed.pem /etc/ssl/fake/fake_self_signed.pem
COPY ssl/fake_self_signed.crt /etc/ssl/fake/fake_self_signed.crt

WORKDIR /etc/ssl/certs/user
VOLUME /etc/ssl/certs/user
VOLUME /etc/ssl/private

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/revrse_proxy_params /etc/nginx/revrse_proxy_params
COPY nginx/conf.d/ /etc/nginx/conf.d/

RUN cd / && tar czf /nginx.tar.xz etc/nginx
VOLUME /etc/nginx

WORKDIR /var/www
WORKDIR /var/www/html
COPY index.html /var/www/html/index.html

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx"]
