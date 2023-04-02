#!/bin/bash

if ! command -v kubectl &> /dev/null; then
    echo 'kubectl is not installed'
    exit 1
fi

# Aplicar padrões globais
function apply_global_patterns() {
    kubectl apply -f yaml_hpa/cpu-defaults.yaml
}

# Instalar cert-manager
function install_cert_manager() {
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
}

# Instalar servidor de métricas do Kubernetes
function install_metrics_server() {
    kubectl apply -f yaml_hpa/components.yaml
}

# Instalar alta disponibilidade
function install_high_availability() {
    kubectl apply -f yaml_hpa/high-availability-1.21+.yaml
}

# Aplicar recursos do Nextcloud
function apply_nextcloud_resources() {
    kubectl apply -f yaml_hpa/namespace.yml
    kubectl apply -f yaml_hpa/hpa.yml
    kubectl apply -f yaml_nextcloud/cluster-ingress.yml
    kubectl apply -f yaml_nextcloud/nextcloud-pvc.yml
    kubectl apply -f yaml_nextcloud/nextcloud-server.yml
    kubectl apply -f yaml_nextcloud/tls.yml
}

# Criar secret para banco de dados do Nextcloud
function create_nextcloud_db_secret() {
    kubectl create secret generic nextcloud-db-secret --from-literal=POSTGRES_USER=nextcloud --from-literal=POSTGRES_PASSWORD=902grego1989
}

# Aplicar recursos do banco de dados do Nextcloud
function apply_nextcloud_db_resources() {
    kubectl apply -f yaml_bd/nextcloud-db.yml
    kubectl apply -f yaml_bd/nextcloud-pvc.yml
}

# Deletar LimitRange
function delete_limit_range() {
    kubectl get LimitRange -n nextcloud
    kubectl delete LimitRange  -n nextcloud limit-range-default
    kubectl describe limits --namespace=default
    kubectl describe hpa -n nextcloud
}

# Chamar funções de acordo com a necessidade
apply_global_patterns
#install_cert_manager
#install_metrics_server
#install_high_availability
apply_nextcloud_resources
#create_nextcloud_db_secret
#apply_nextcloud_db_resources
#delete_limit_range