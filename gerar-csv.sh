#!/bin/bash
JSON=portal.json
CSV_HIST=covid19-br.csv

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" -H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" --compressed -o $JSON

echo "Fazendo download do arquivo ZIP"
curl -# -O -J $(jq -r '.results[0].arquivo.url' $JSON)

echo "Descompactando o arquivo CSV"
unzip -p $(jq -r '.results[0].arquivo.name' $JSON) > $CSV_HIST
