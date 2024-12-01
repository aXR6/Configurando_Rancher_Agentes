# Usar imagem base do Nginx
FROM nginx:alpine

# Instalar pacotes necessários para compilar módulos e Redis module
RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    libc-dev \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    wget \
    curl \
    git \
    && wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | awk -F/ '{print $2}').tar.gz \
    && tar zxvf nginx-*.tar.gz \
    && cd nginx-* \
    && git clone https://github.com/openresty/redis2-nginx-module.git \
    && ./configure --with-compat --add-dynamic-module=./redis2-nginx-module \
    && make modules \
    && cp objs/ngx_http_redis2_module.so /etc/nginx/modules \
    && cd .. \
    && rm -rf nginx-* \
    && apk del gcc g++ make libc-dev pcre-dev zlib-dev openssl-dev linux-headers libxslt-dev gd-dev geoip-dev perl-dev wget curl git

# Copiar o nginx.conf padrão e incluir o módulo Redis
COPY nginx.conf ./nginx/nginx.conf
COPY conf.d ./nginx/conf.d

# Expor as portas HTTP e HTTPS
EXPOSE 80 443

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]