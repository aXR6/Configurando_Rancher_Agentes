#!/bin/bash

# Verifica se o kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo 'kubectl não está instalado'
    exit 1
fi

# Aplica os arquivos YAML
kubectl apply -f rbac.yml -f docker-clean.yml -f k8s-clean.yml -f etcd-empty-dir-cleanup.yml -n kube-system