FROM nginx:latest

# Instalar os pacotes necessários para suporte ao módulo Redis
RUN apt-get update && apt-get install -y \
    libnginx-mod-http-redis \
    libnginx-mod-http-cache-purge \
    && rm -rf /var/lib/apt/lists/*

# Copiar a configuração personalizada para o contêiner
COPY ./conf.d /etc/nginx/conf.d