FROM alpine

ENV ETCD_VERSION=3.1.4
ENV KUBE_VERSION=1.7.8

# Instala as dependências e remove o cache dos pacotes baixados
RUN apk add --update bash curl docker && \
    rm -rf /var/cache/apk/*

# Baixa e instala o kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Baixa e instala o etcdctl
RUN curl -LO https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz && \
    tar -xzf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz && \
    mv etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl && \
    rm -rf etcd-v${ETCD_VERSION}-linux-amd64* && \
    chmod +x /usr/local/bin/etcdctl

# Copia os scripts de limpeza para /bin e define as variáveis de ambiente
COPY docker-clean.sh k8s-clean.sh etcd-empty-dir-cleanup.sh /bin/
RUN chmod +x /bin/docker-clean.sh /bin/k8s-clean.sh /bin/etcd-empty-dir-cleanup.sh
ENV DOCKER_CLEAN_INTERVAL=1800
ENV DAYS=7

# Executa o script de limpeza do Docker como comando padrão
CMD ["/bin/bash", "/bin/docker-clean.sh"]