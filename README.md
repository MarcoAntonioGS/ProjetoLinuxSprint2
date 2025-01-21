# Projeto Linux Sprint 2
Este projeto contém um script para monitoramento do serviço Nginx em um ambiente Linux. O script verifica periodicamente o status do serviço e armazena logs localmente, além de enviá-los para um bucket S3 na AWS.

## Funcionalidades
- Verificação do status do serviço Nginx
- Registro de logs de status localmente
- Envio dos logs para um bucket S3 configurado
- Gerenciamento básico de permissões e limpeza de logs antigos

## Tecnologias usadas 
- Amazon EC2
- Amazon Systems Manager
- AWS IAM
- AMI Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
- Amazon S3
- Nginx
  
## Pré Requisitos 
- Crie uma IAM role do tipo AWS service EC2 com as políticas de permissões AmazonS3FullAccess e AmazonSSMManagedInstanceCore
- Criar um bucket padrão no Amazon S3
- Criar uma instância Ubuntu Server 24.04 LTS (HVM), SSD Volume Type com a IAM role criada e com um endereço de ip público 
- Configurar o security group para permitir a conexão HTTP na porta 80 com o seu ip
- Configurar o gateway de internet e a tabela de rotas para permitir a conexão com a internet, se ainda não tiver configurado

## Passo a Passo do Projeto
  ### Coloque esses comandos na política do seu Bucket
  ```
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::seu-bucket-s3/*",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/nome-da-role"
      }
    }
  ]
}
```
### Se conectar na instâcia no console AWS com o session manager

### Instalar o Nginx
```
$sudo apt update -y
$sudo apt install nginx -y
$sudo systemctl enable nginx
```
### Verificar se o nginx está rodando
```
$sudo systemctl start nginx
$sudo systemctl status nginx
```
### Criar o Script de Validação do Serviço Nginx
Criar o arquivo do script de monitoramento:
`$sudo nano /usr/local/bin/monitor_nginx.sh`

Adicione o seguinte conteúdo ao script:
```
#!/bin/bash

`LOG_DIR="/var/log/nginx-monitor"`
`ONLINE_LOG="$LOG_DIR/online.log"`
OFFLINE_LOG="$LOG_DIR/offline.log"
BUCKET_NAME="Seu-Bucket"

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
```
### Tornar o script executável:
`$sudo chmod +x /usr/local/bin/monitor_nginx.sh`

### Para agendar a execução do script a cada 5 minutos:
`$sudo crontab -e`

Adicione a linha:
`*/5 * * * * /usr/local/bin/monitor_nginx.sh`

### Para aplicar as configurações:
`$sudo systemctl restart crond`

### Testar o Script Manualmente
`$sudo /usr/local/bin/monitor_nginx.sh`

### Verifique os arquivos de log:
```
$cat /var/log/nginx-monitor/online.log
$cat /var/log/nginx-monitor/offline.log
```
### Parar o serviço Nginx manualmente:
```
$sudo systemctl stop nginx
$sudo systemctl start nginx
```
### Verificar se o cron está ativo:
`$sudo systemctl status cron`

  Confirmar se a tarefa foi agendada corretamente:
 `$sudo crontab -l`

### Para testar manualmente o cron mais rapidamente:
  Altere o intervalo para 1 minuto (somente para teste):
  `$sudo crontab -e`
  
  Modifique para:
  `* * * * * /usr/local/bin/monitor_nginx.sh`
  
## Versinamento com o git
```
sudo apt update
sudo apt install git -y
cd /usr/local/bin
sudo git init
sudo git add monitor_nginx.sh
sudo git commit -m "Adicionando script de monitoramento Nginx"
```
### Clone o Repositório para o seu servidor
`git clone https://github.com/MarcoAntonioGS/ProjetoLinuxSprint2.git`




