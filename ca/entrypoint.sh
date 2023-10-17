#!/bin/sh

# 機密情報の読み出し
if [ "$SECRET_FILE" != '' -a -f "$SECRET_FILE" ]; then
  source "$SECRET_FILE"
fi


# ルートCA

if [ ! -d $ROOT_CA_DIR -o $(ls $ROOT_CA_DIR | wc -l ) == 0 ]; then
  sh $SCRIPT_DIR/generate_root
  if [ $? -ne 0 ]; then
    echo "Can't build root CA." > /dev/stderr
    exit 1
  fi
fi

if [ ! -f $CA_WWW_DIR/root_ca.crt ]; then
  ln -s $ROOT_CA_DIR/certs/root_ca.crt $CA_WWW_DIR/root_ca.crt
fi


# 中間CA

if [ ! -d $INTER_CA_DIR -o $(ls $INTER_CA_DIR | wc -l ) == 0 ]; then
  sh $SCRIPT_DIR/generate_intermediate
  if [ $? -ne 0 ]; then
    echo "Can't build intermediate CA." > /dev/stderr
    exit 1
  fi
fi

if [ ! -f $CA_WWW_DIR/inter_ca.crt ]; then
  ln -s $INTER_CA_DIR/certs/inter_ca.crt $CA_WWW_DIR/inter_ca.crt
fi


# CRL

sh $SCRIPT_DIR/generate_crl
if [ $? -ne 0 ]; then
  echo "Can't generate CRL files" > /dev/stderr
  exit 1
fi


# OCSP

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

# nginx

exec $@
