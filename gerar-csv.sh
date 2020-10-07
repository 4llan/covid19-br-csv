#!/bin/bash
JSON=portal.json
CSV_HIST=covid19-br.csv

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" -H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" --compressed -o $JSON

PORTAL_ARQUIVO=$(jq -r '.results[0].arquivo.name' $JSON)

echo "Fazendo download do arquivo"
curl -# -O -J $(jq -r '.results[0].arquivo.url' $JSON)

if [[ $PORTAL_ARQUIVO == *".zip" ]]; then
    echo "Descompactando o arquivo CSV"
    unzip -p $PORTAL_ARQUIVO > $CSV_HIST
else
    if [[ $PORTAL_ARQUIVO == *".csv" ]]; then
        echo "Substituindo o arquivo CSV"
        cat $PORTAL_ARQUIVO > $CSV_HIST
        rm $PORTAL_ARQUIVO
    else
        echo "Pela 300a vez no ano, o Ministério da Saúde mudou o formato do dado disponibilizado"
    fi
fi
