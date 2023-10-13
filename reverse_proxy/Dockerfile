FROM nginx:alpine

EXPOSE 80
EXPOSE 443

RUN apk update && apk upgrade

COPY ssl/fake_self_signed.pem /etc/ssl/private/fake_self_signed.pem
COPY ssl/fake_self_signed.crt /etc/ssl/certs/fake_self_signed.crt

RUN cp /etc/ssl/private/fake_self_signed.pem /etc/ssl/private/localdomain.nopass.pem \
 && cp /etc/ssl/certs/fake_self_signed.crt   /etc/ssl/certs/localdomain.chain.crt 

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/revrse_proxy_params /etc/nginx/revrse_proxy_params
COPY nginx/conf.d/ /etc/nginx/conf.d/

WORKDIR /var/www
WORKDIR /var/www/html
COPY index.html /var/www/html/index.html
