#!/bin/bash
JSON=portal.json
CSV_HIST=covid19-br.csv

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" -H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" --compressed -o $JSON

PORTAL_ARQUIVO=$(jq -r '.results[0].arquivo.name' $JSON)

echo "Fazendo download do arquivo"
curl -# -O -J $(jq -r '.results[0].arquivo.url' $JSON)

case "${PORTAL_ARQUIVO##*.}" in
    "zip")
        echo "Descompactando o arquivo CSV"
        unzip -p $PORTAL_ARQUIVO > $CSV_HIST
        ;;
    "csv")
        echo "Substituindo o arquivo CSV"
        cat $PORTAL_ARQUIVO > $CSV_HIST
        rm $PORTAL_ARQUIVO
        ;;
    "rar")
        echo "Descompactando o arquivo RAR"
        unrar x -o+ $PORTAL_ARQUIVO
        tmpcsv=$(find . -maxdepth 1 -name "HIST*.csv")
        cat $tmpcsv > $CSV_HIST
        rm $tmpcsv
        ;;
    *)
        echo "Pela 301a vez no ano, o Ministério da Saúde mudou o formato do dado disponibilizado"
        ;;
esac
