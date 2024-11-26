FROM debian:bullseye

# Instala dependências necessárias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gcc \
    make \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    build-essential

# Diretório de compilação
WORKDIR /usr/src/nginx

# Baixa o Nginx e o módulo Redis
RUN wget http://nginx.org/download/nginx-1.22.1.tar.gz && \
    tar -xzvf nginx-1.22.1.tar.gz && \
    wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz && \
    tar -xzvf ngx_http_redis-0.3.9.tar.gz

# Compila o Nginx com o módulo Redis
RUN cd nginx-1.22.1 && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_gzip_static_module \
        --add-module=/usr/src/nginx/ngx_http_redis-0.3.9 && \
    make && \
    make install

# Remove ferramentas de construção para reduzir o tamanho da imagem
RUN apt-get purge -y --auto-remove \
    gcc \
    make \
    build-essential && \
    apt-get clean && \
    rm -rf /usr/src/nginx

# Define o diretório de trabalho para o Nginx
WORKDIR /etc/nginx

# Expõe a porta padrão
EXPOSE 80

# Comando padrão para inicializar o Nginx
CMD ["nginx", "-g", "daemon off;"]
