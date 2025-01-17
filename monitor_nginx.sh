#!/bin/bash

LOG_DIR="/var/log/nginx-monitor"
ONLINE_LOG="$LOG_DIR/online.log"
OFFLINE_LOG="$LOG_DIR/offline.log"
BUCKET_NAME="seu-bucket"

# Cria o diretório de log caso não exista
mkdir -p "$LOG_DIR"

# Cria os arquivos de log caso não existam
touch "$ONLINE_LOG"
touch "$OFFLINE_LOG"

# Garantir permissões corretas
sudo chmod 755 "$LOG_DIR"
sudo chmod 644 "$ONLINE_LOG" "$OFFLINE_LOG"

# Obtém a data e hora atuais
DATA_HORA=$(date +"%Y-%m-%d %H:%M:%S")

# Verifica o status do serviço nginx uma vez
if systemctl is-active --quiet nginx; then
    MENSAGEM="$DATA_HORA - nginx - ONLINE - O serviço está funcionando corretamente."
    echo "$MENSAGEM" >> "$ONLINE_LOG"
    aws s3 cp "$ONLINE_LOG" "s3://$BUCKET_NAME/online.log"
else
    MENSAGEM="$DATA_HORA - nginx - OFFLINE - ATENÇÃO! Serviço fora do ar."
    echo "$MENSAGEM" >> "$OFFLINE_LOG"
    aws s3 cp "$OFFLINE_LOG" "s3://$BUCKET_NAME/offline.log"
fi

# Exibe a mensagem apenas uma vez no terminal
echo "$MENSAGEM"


