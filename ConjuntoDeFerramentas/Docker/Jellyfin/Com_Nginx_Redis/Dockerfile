FROM nginx:latest

RUN apt-get update && apt-get install -y \
    wget \
    gcc \
    make \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    && mkdir -p /usr/src/nginx \
    && cd /usr/src/nginx \
    && wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | awk -F/ '{print $2}').tar.gz \
    && tar -xzvf nginx-*.tar.gz \
    && cd nginx-* \
    && wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz \
    && tar -xzvf ngx_http_redis-*.tar.gz \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_gzip_static_module \
        --add-module=/usr/src/nginx/ngx_http_redis-0.3.9 \
    && make \
    && make install \
    && apt-get purge -y --auto-remove \
        gcc \
        make \
    && rm -rf /usr/src/nginx
