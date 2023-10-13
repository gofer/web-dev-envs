#!/bin/sh

# 機密情報の読み出し
if [ "$SECRET_FILE" != '' -a -f "$SECRET_FILE" ]; then
  source "$SECRET_FILE"
fi

if [ ! -d $ROOT_CA_DIR ]; then
  sh $SCRIPT_DIR/generate_root
  if [ $? -ne 0 ]; then
    echo "Can't build root CA." > /dev/stderr
    exit 1
  fi
fi

if [ ! -d $INTER_CA_DIR ]; then
  sh $SCRIPT_DIR/generate_intermediate
  if [ $? -ne 0 ]; then
    echo "Can't build intermediate CA." > /dev/stderr
    exit 1
  fi
fi

sh $SCRIPT_DIR/generate_crl
if [ $? -ne 0 ]; then
  echo "Can't generate CRL files" > /dev/stderr
  exit 1
fi

if [ $(pgrep nginx | wc -l) -eq 0 ]; then
  nginx -c /etc/nginx/nginx.conf
fi

sh $SCRIPT_DIR/ocsp_root &
if [ $? -ne 0 ]; then
  echo "Can't start root CA OCSP responder." > /dev/stderr
  exit 1
fi
echo $! > /run/ocsp_root.pid

sh $SCRIPT_DIR/ocsp_inter &
if [ $? -ne 0 ]; then
  echo "Can't start intermediate CA OCSP responder." > /dev/stderr
  exit 1
fi
echo $! > /run/ocsp_inter.pid

while :; do
  sleep 3600
done
