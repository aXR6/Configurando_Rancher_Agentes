FROM nginx:latest

# Instalar o módulo Memcached para Nginx
RUN apt-get update && apt-get install -y \
    libnginx-mod-stream \
    libnginx-mod-http-cache-purge \
    libnginx-mod-http-upstream-fair \
    libnginx-mod-http-memcached \
    && rm -rf /var/lib/apt/lists/*

# Copiar configurações para o contêiner
COPY ./conf.d /etc/nginx/conf.d