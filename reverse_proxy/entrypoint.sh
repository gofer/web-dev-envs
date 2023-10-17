#!/bin/sh

if [ ! -f /etc/ssl/private/localdomain.nopass.pem ]; then
  cp /etc/ssl/fake/fake_self_signed.pem \
     /etc/ssl/private/localdomain.nopass.pem
fi

if [ ! -f /etc/ssl/certs/user/localdomain.chain.crt ]; then
  cp /etc/ssl/fake/fake_self_signed.crt \
     /etc/ssl/certs/user/localdomain.chain.crt
fi


cd /; tar xf /nginx.tar.xz


exec $@
