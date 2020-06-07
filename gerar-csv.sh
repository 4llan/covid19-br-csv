#!/bin/bash
JSON=portal.json
CSV=covid19-br.csv

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" \
-H "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4" \
-H "Accept: application/json, text/plain, */*" \
--compressed \
-H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" \
-H "Origin: https://covid.saude.gov.br" \
-H "DNT: 1" \
-H "Connection: keep-alive" \
-H "Referer: https://covid.saude.gov.br/" \
-H "Pragma: no-cache" \
-H "Cache-Control: no-cache" \
-H "TE: Trailers" > $JSON

echo "Fazendo download do arquivo XLSX"
curl -# -O -J $(jq -r '.results[0].arquivo.url' $JSON)

echo "Convertendo o XLSX em CSV"
xlsx2csv -f "%Y-%m-%d" $(jq -r '.results[0].arquivo.name' $JSON) $CSV
