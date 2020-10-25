# covid19-br-csv
O objetivo deste repositório era manter o histórico do arquivo divulgado diariamente pelo Ministério da Saúde sobre os casos notificados do COVID-19 no Brasil em formato CSV. Como o arquivo CSV ultrapassou o limite de 100MB, então agora será arquivado no formato gzip.

## Dependências

* curl
* jq
* xlsx2csv
* unzip
* unrar-free
* gzip
* sha1sum


## Automações

### [GitHub Actions](.github/workflows/gerar-csv.yml)
Para manter o arquivo [covid19-br.csv.gz](covid19-br.csv.gz) atualizado, utiliza-se o Github Actions com uma tarefa agendada para executar o script [gerar-csv.sh](gerar-csv.sh) duas vezes por dia: 19:30 e 03:30 (UTC-3).

### [Google Cloud Build](cloudbuild.yaml)
Para copiar o arquivo [covid19-br.csv.gz](covid19-br.csv.gz) automaticamente para um bucket do Google Cloud Storage a cada novo commit que o modifica, utiliza-se um gatilho do Google Cloud Build com as seguintes propriedades:

Propriedade | Valor
--- | ---
Event | `Push to a branch`
Source | `.*`
Included files filter (glob) | `*.gz`
Build configuration | `Cloud Build configuration file (yaml or json)`
Cloud Build configuration file location | `/cloudbuild.yaml`
Substitution variables > Variable | `_BUCKET_NAME`
Substitution variables > Value | Substitua pelo nome do seu bucket
