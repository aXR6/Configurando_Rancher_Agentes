FROM nginx:alpine

RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    git \
    redis && \
    cd /tmp && \
    git clone https://github.com/nginx/nginx.git && \
    git clone https://github.com/openresty/redis2-nginx-module.git && \
    cd nginx && \
    ./auto/configure \
        --add-module=/tmp/redis2-nginx-module \
        --with-http_ssl_module && \
    make && \
    make install && \
    rm -rf /tmp/nginx /tmp/redis2-nginx-module