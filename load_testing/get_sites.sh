#!/usr/bin/env bash

# Script used to retrieve random website.  Using a site called uroulett.com to populate
# Domains outputted might be in a weird format, so some data massaging might be needed.

OUT_FILE=websites.txt

for i in {0..50}; do
  URL=$(curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" -Ls -o /dev/null -w %{url_effective} https://uroulette.com/visit/opwupn)
  TMP=(${URL//\/\// })
  echo ${TMP[1]%%/*} >> ${OUT_FILE}
done
