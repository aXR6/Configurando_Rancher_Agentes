FROM nginx:alpine
RUN apk add --no-cache gcc libc-dev make pcre-dev zlib-dev openssl-dev git \
    && git clone https://github.com/openresty/redis2-nginx-module /usr/src/redis2-nginx-module \
    && git clone https://github.com/nginx/nginx /usr/src/nginx \
    && cd /usr/src/nginx \
    && ./auto/configure --add-module=/usr/src/redis2-nginx-module --with-http_ssl_module \
    && make && make install
