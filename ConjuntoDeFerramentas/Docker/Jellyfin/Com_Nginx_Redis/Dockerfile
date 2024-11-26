FROM debian:bullseye-slim

# Variáveis de ambiente para facilitar a manutenção
ENV NGINX_VERSION=1.24.0 \
    NGINX_DEVEL_KIT_VERSION=0.3.2 \
    NGINX_REDIS_MODULE_VERSION=0.3.9

# Instalação de dependências para compilar o Nginx
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    curl \
    git \
    wget \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Baixar e compilar o Nginx
WORKDIR /usr/src/nginx
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar -xzvf nginx-$NGINX_VERSION.tar.gz && \
    wget https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEVEL_KIT_VERSION.tar.gz && \
    tar -xzvf v$NGINX_DEVEL_KIT_VERSION.tar.gz && \
    wget https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v$NGINX_REDIS_MODULE_VERSION.tar.gz && \
    tar -xzvf v$NGINX_REDIS_MODULE_VERSION.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --add-module=../ngx_devel_kit-$NGINX_DEVEL_KIT_VERSION \
        --add-module=../redis2-nginx-module-$NGINX_REDIS_MODULE_VERSION && \
    make && make install

# Limpeza de arquivos de compilação
RUN apt-get purge -y build-essential git wget && \
    apt-get autoremove -y && \
    rm -rf /usr/src/nginx && \
    rm -rf /var/lib/apt/lists/*

# Diretório para cache do Nginx
RUN mkdir -p /var/cache/nginx && chown -R www-data:www-data /var/cache/nginx

# Diretório de configuração customizada
COPY ./conf.d /etc/nginx/conf.d

# Comando padrão para iniciar o Nginx
CMD ["nginx", "-g", "daemon off;"]