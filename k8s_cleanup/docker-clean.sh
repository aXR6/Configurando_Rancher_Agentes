#!/bin/bash

# Define o intervalo de limpeza em segundos (30 minutos)
DOCKER_CLEAN_INTERVAL=1800

# Função para realizar a limpeza do Docker
docker_clean() {
  echo "Iniciando a limpeza do Docker em $(date +%F\ %T)"
  # Remove todas as imagens, volumes e containers não utilizados
  docker system prune --all --force
  # Remove todos os volumes não utilizados
  docker volume prune --force
  # Remove todas as imagens com a label "deprecated"
  docker image prune --force --filter="label=deprecated"
  echo "Limpeza do Docker realizada em $(date +%F\ %T)"
}

# Executa a limpeza do Docker e espera o intervalo definido
while true; do
  docker_clean
  sleep $DOCKER_CLEAN_INTERVAL
done