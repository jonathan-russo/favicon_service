#!/usr/bin/env bash

SERVICE_ADDR=http://127.0.0.1:8000/favicon

cat websites.txt | parallel "ab -n 5 ${SERVICE_ADDR}/https:{}/ | grep \"Path\|Failed\|second:\""

# while true; do
#   RANDOM_HOST=$(shuf -n 1 websites.txt)
#   echo "Fetching for ${RANDOM_HOST}"
#   time curl -s -o /dev/null -w "%{http_code}" ${SERVICE_ADDR}/https:${RANDOM_HOST}/
#   sleep 1
# done