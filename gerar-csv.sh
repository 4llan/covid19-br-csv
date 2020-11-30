#!/bin/bash
JSON=portal.json
CSV_HIST=covid19-br.csv
updatedAt=last-update.txt

echo "Fazendo download do arquivo JSON"
curl -# "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral" -H "X-Parse-Application-Id: unAFkcaNDeXajurGB7LChj8SgQYS2ptm" --compressed -o $JSON

[ $(jq -r '.results[0].updatedAt' $JSON) == $(cat $updatedAt) ] && cat $updatedAt && exit 0

PORTAL_ARQUIVO=$(jq -r '.results[0].arquivo.name' $JSON)

echo "Fazendo download do arquivo"
curl -f -# -O -J $(jq -r '.results[0].arquivo.url' $JSON)
[ $? -ne 0 ] && exit 1

[ -f "$CSV_HIST.gz" ] && gzip -d -c $CSV_HIST.gz > $CSV_HIST
case "${PORTAL_ARQUIVO##*.}" in
    "xlsx")
        echo "Convertendo o XLSX em CSV"
        xlsx2csv -f "%Y-%m-%d" $PORTAL_ARQUIVO $PORTAL_ARQUIVO.csv

        DELETE_XLSXCSV=1

        if [[ $PORTAL_ARQUIVO == *"HIST"* ]]; then
            echo "> HIST"
            cat $PORTAL_ARQUIVO.csv > $CSV_HIST
        else
            echo "> HOJE"
            if [[ $(head -1 $CSV_HIST) == $(head -1 $PORTAL_ARQUIVO.csv) ]]; then
                tail -n+2 $PORTAL_ARQUIVO.csv >> $CSV_HIST
            else
                echo "> O cabeçalho dos arquivos CSV estão diferentes. Não será possível mesclar conteúdo no arquivo principal"
                DELETE_XLSXCSV=0
            fi
        fi

        [ $DELETE_XLSXCSV -eq 1 ] && rm $PORTAL_ARQUIVO.csv
        ;;
    "zip")
        echo "Descompactando o arquivo ZIP"
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
        exit 1
        ;;
esac
sha1sum -c --status "$CSV_HIST.sha1"
[ $? -ne 0 ] && sha1sum "$CSV_HIST" > $CSV_HIST.sha1 && gzip -f $CSV_HIST
[ -f "$CSV_HIST" ] && rm -rf $CSV_HIST
jq -r '.results[0].updatedAt' $JSON > $updatedAt
exit 0
