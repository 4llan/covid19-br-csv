# covid19-br-csv
O objetivo deste repositório é manter o arquivo XLSX divulgado diariamente pelo Ministério da Saúde sobre os casos notificados do COVID-19 no Brasil em formato CSV.

Para manter o arquivo [covid19-br.csv](covid19-br.csv) atualizado, utiliza-se o Github Actions com uma tarefa agendada para executar o script [gerar-csv.sh](gerar-csv.sh) duas vezes por dia: 18:30 e 03:30 (UTC-3).

## Dependências

* curl
* jq
* xlsx2csv
