FROM nginx:alpine

RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    redis \
    git && \
    cd /usr/local/src && \
    git clone https://github.com/openresty/redis2-nginx-module.git && \
    git clone https://github.com/nginx/nginx.git && \
    cd nginx && \
    ./auto/configure --add-module=/usr/local/src/redis2-nginx-module --with-http_ssl_module && \
    make && \
    make install

CMD ["nginx", "-g", "daemon off;"]