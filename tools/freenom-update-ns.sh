#!/bin/bash
##########################################################
# Script to modify domain in freenom
##########################################################
set -e

[ -z "$FREENOM_EMAIL" ] && echo "FREENOM_EMAIL not set" && exit 1
[ -z "$FREENOM_PASSWORD" ] && echo "FREENOM_PASSWORD not set" && exit 1
[ -z "$FREENOM_DOMAIN" ] && echo "FREENOM_DOMAIN not set" && exit 1
# apiUrl=${FREENOM_API_URL:="https://api.freenom.com/v2/domain/modify"}
apiUrl=https://api.freenom.com/v2/domain/getinfo

nameservers=$@

for nameserver in nameservers
do
  nsparam="$nsparam&nameserver=$nameserver"
done

# echo "NS Pre Changes"
dig $FREENOM_DOMAIN

echo "Begin update of $FREENOM_DOMAIN"

# data="domainname=${FREENOM_DOMAIN}&${nsparam}"
data="domainname=${FREENOM_DOMAIN}&email=${FREENOM_EMAIL}&password=${FREENOM_PASSWORD}"

result=$(curl -s -X GET \
  -H "Content-Type: application/json" \
  -d ${data} ${apiUrl} | jq -rM '.status')

echo $result

dig $FREENOM_DOMAIN