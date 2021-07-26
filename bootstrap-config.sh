#!/bin/bash
set -e

# This will generate a default set of configuration
# designed for an installation which is running using
# Docker.

output_path=$1

if [ "$output_path" == "" ]; then
  echo 'no path provided'
  exit 1
fi

mkdir -p $output_path

if [ ! -f $output_path/postal.yml ]; then
  echo "=> Creating $output_path/postal.yml"
  cp postal.example.yml $output_path/postal.yml
  rails_secret_key=`openssl rand -hex 128 | tr -d '\n'`
  sed -i "s/{{secretkey}}/$rails_secret_key/" $output_path/postal.yml
fi

if [ ! -f $output_path/lets_encrypt.pem ]; then
  echo '=> Creating lets encrypt private key'
  openssl genrsa -out $output_path/lets_encrypt.pem 2048
fi

if [ ! -f $output_path/signing.key ]; then
  echo '=> Creating signing private key'
  openssl genrsa -out $output_path/signing.key 1024
fi

if [ ! -f $output_path/fast_server.cert ]; then
  echo '=> Creating fast server default private key'
  openssl req -x509 -nodes \
    -newkey rsa:2048 \
    -keyout $output_path/fast_server.key \
    -out $output_path/fast_server.cert \
    -days 3650 \
    -subj '/CN=default'
fi
