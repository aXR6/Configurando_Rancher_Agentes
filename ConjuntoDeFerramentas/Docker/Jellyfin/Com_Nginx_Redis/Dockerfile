FROM nginx:alpine

# Instalar dependências necessárias
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    git && \
    mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    git clone https://github.com/openresty/redis2-nginx-module.git && \
    git clone https://github.com/nginx/nginx.git && \
    cd nginx && \
    ./auto/configure --add-module=/usr/local/src/redis2-nginx-module --with-http_ssl_module --with-http_v2_module && \
    make && \
    make install

CMD ["nginx", "-g", "daemon off;"]