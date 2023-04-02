#!/bin/bash

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 is not installed"
        exit 1
    fi
}

apply_resource() {
    kubectl apply -f "$1"
}

# Verificar se o kubectl está instalado
check_command kubectl

# Aplicar os recursos
apply_resource namespace.yml
apply_resource tls.yml
apply_resource persistenVolume/media-persistVolume.yml

for resource in jackett/jackett-svc.yml radarr/radarr-service.yml sonarr/sonarr-svc.yml transmission/transmission-service.yml; do
    apply_resource "$resource"
done

for resource in jackett/jackett-ingress.yml jackett/deployment.yml radarr/radarr-ingress.yml radarr/deployment.yml sonarr/sonarr-ingress.yml sonarr/deployment.yml transmission/transmission-ingress.yml transmission/deployment.yml; do
    apply_resource "$resource"
done

apply_resource hpa.yml
apply_resource components.yaml

# Instalar o cert-manager
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# Alta disponibilidade
# Precisa ter + de 2 nós
# kubectl apply -f high-availability-1.21+.yaml