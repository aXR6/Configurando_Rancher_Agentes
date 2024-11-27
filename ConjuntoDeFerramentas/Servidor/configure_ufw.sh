#!/bin/bash

# Nome do arquivo de log
LOG_FILE="/var/log/ufw_reset_and_configure_$(date +%Y%m%d%H%M%S).log"

# Função para registrar logs
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    log "Por favor, execute este script como root."
    exit 1
fi

log "Iniciando limpeza e configuração do UFW..."

# Desativar o UFW
log "Desativando o UFW..."
ufw disable 2>&1 | tee -a "$LOG_FILE"

# Redefinir o UFW
log "Redefinindo todas as configurações do UFW para o estado padrão..."
ufw --force reset 2>&1 | tee -a "$LOG_FILE"

# Configurar políticas padrão
log "Definindo as políticas padrão: negar conexões de entrada e permitir conexões de saída..."
ufw default deny incoming 2>&1 | tee -a "$LOG_FILE"
ufw default allow outgoing 2>&1 | tee -a "$LOG_FILE"

# Permitir tráfego para os serviços especificados
log "Permitindo conexões de entrada para as portas usadas pelo projeto..."

# Jellyfin
ufw allow 8096/tcp comment 'Jellyfin HTTP' 2>&1 | tee -a "$LOG_FILE"
ufw allow 8920/tcp comment 'Jellyfin HTTPS' 2>&1 | tee -a "$LOG_FILE"

# Nginx
ufw allow 80/tcp comment 'Nginx HTTP' 2>&1 | tee -a "$LOG_FILE"
ufw allow 443/tcp comment 'Nginx HTTPS' 2>&1 | tee -a "$LOG_FILE"

# Memcached
ufw allow 11211/tcp comment 'Memcached Cache' 2>&1 | tee -a "$LOG_FILE"

# Permitir tráfego de saída para o Cloudflare (para o túnel funcionar)
log "Permitindo conexões de saída necessárias para o Cloudflare..."
ufw allow out 7844/tcp comment 'Cloudflare Tunnel' 2>&1 | tee -a "$LOG_FILE"
ufw allow out 443/tcp comment 'HTTPS para Cloudflare' 2>&1 | tee -a "$LOG_FILE"

# Permitir conexões apenas da rede Cloudflare para os serviços públicos (opcional)
log "Permitindo conexões para Nginx apenas de IPs da rede Cloudflare..."
for ip in $(curl -s https://www.cloudflare.com/ips-v4); do
    ufw allow from "$ip" to any port 80,443 proto tcp comment 'Cloudflare IP' 2>&1 | tee -a "$LOG_FILE"
done

# Recarregar o UFW para aplicar as alterações
log "Recarregando as regras do UFW..."
ufw reload 2>&1 | tee -a "$LOG_FILE"

# Ativar o UFW
log "Habilitando o UFW..."
ufw --force enable 2>&1 | tee -a "$LOG_FILE"

# Exibir o status do UFW
log "Exibindo o status do UFW após a configuração..."
ufw status verbose | tee -a "$LOG_FILE"

log "Configuração do UFW concluída com sucesso. Logs salvos em $LOG_FILE"