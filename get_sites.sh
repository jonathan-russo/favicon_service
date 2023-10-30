#!/usr/bin/env bash

OUT_FILE=websites.txt

for i in {0..50}; do
  URL=$(curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" -Ls -o /dev/null -w %{url_effective} https://uroulette.com/visit/opwupn)
  TMP=(${URL//\/\// })
  echo ${TMP[1]%%/*} >> ${OUT_FILE}
done
