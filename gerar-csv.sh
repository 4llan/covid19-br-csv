#!/bin/bash
JSON=portal.json
CSV_HIST=covid19-br.csv

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" -H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" --compressed -o $JSON

XLSX_URL=$(jq -r '.results[0].arquivo.url' $JSON)
XLSX_FILENAME=$(jq -r '.results[0].arquivo.name' $JSON)

echo "Fazendo download do arquivo XLSX"
curl -# -O -J $XLSX_URL

echo "Convertendo o XLSX em CSV"
xlsx2csv -f "%Y-%m-%d" $XLSX_FILENAME $XLSX_FILENAME.csv

DELETE_XLSXCSV=1

if [[ $XLSX_FILENAME == *"HIST"* ]]; then
    echo "> HIST"
    cat $XLSX_FILENAME.csv > $CSV_HIST
else
    echo "> HOJE"
    if [[ $(head -1 $CSV_HIST) == $(head -1 $XLSX_FILENAME.csv) ]]; then
        tail -n+2 $XLSX_FILENAME.csv >> $CSV_HIST
    else
        echo "> O cabeçalho dos arquivos CSV estão diferentes. Não será possível mesclar conteúdo no arquivo principal"
        DELETE_XLSXCSV=0
    fi
fi

[ $DELETE_XLSXCSV -eq 1 ] && rm $XLSX_FILENAME.csv
