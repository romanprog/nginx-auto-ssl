#!/bin/bash
function get_ssl ()
{
 DOMAIN="$1"
 DOMAIN_SSL_DIR="${SSL_DIR}/${DOMAIN}/"
 mkdir -p "${DOMAIN_SSL_DIR}/acme"
 ACME_CLI_ARGS="-nNv -C /var/www/acme/.well-known/acme-challenge/ \
 -f ${DOMAIN_SSL_DIR}/acme/account.key \
 -k ${DOMAIN_SSL_DIR}/private.key \
 -c ${DOMAIN_SSL_DIR} \
 ${DOMAIN}"
 acme-client ${ACME_CLI_ARGS}
 ACME_ERR=$?
}

SSL_DIR="/etc/nginx/ssl"
IFS=',' read -r -a DOM_ARR <<< "${DOMAINS_LIST}"
ACME_ERR=0
sleep $(( RANDOM % 10 ))
while true; do
  for DM in ${DOM_ARR[@]}; do
    get_ssl ${DM}
  done
# load configs one by one in alphabetical order.
  while read FILE_NAME; do
      if [ -z "${FIRST_RUN}" ]; then
         echo "Copying file ${FILE_NAME}"
         cp /etc/nginx/conf.d/configs/${FILE_NAME} /etc/nginx/conf.d/
      fi
      echo "Checking file ${FILE_NAME}"
      while true; do
         nginx -t
         OUT=$?
         [ ${OUT} -eq 0 ] && break
         sleep 15
      done
      nginx -s reload
  done < <(ls /etc/nginx/conf.d/configs/ | sort -s )

  FIRST_RUN="false"
  sleep 3600
done

while read FILE_NAME
do

done < <(ls | sort -s )