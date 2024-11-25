#!/bin/bash

# Diretórios necessários para o projeto
directories=(
  "/home/stream/jellyfin/config"
  "/home/stream/jellyfin/cache"
  "/home/stream/jellyfin/cache/thumbnails"
  "/home/stream/transmission/downloads/complete"
  "/home/stream/nginx/conf"
  "/home/stream/nginx/logs"
  "/home/stream/nginx/ssl"
  "/var/cache/nginx"
  "/home/stream/redis/data"
)

# Permissões para cada diretório (diretório: dono:grupo:permissões)
permissions=(
  "/home/stream/jellyfin/config:1000:1000:775"
  "/home/stream/jellyfin/cache:1000:1000:775"
  "/home/stream/jellyfin/cache/thumbnails:1000:1000:775"
  "/home/stream/transmission/downloads/complete:1000:1000:775"
  "/home/stream/nginx/conf:1000:1000:755"
  "/home/stream/nginx/logs:1000:1000:755"
  "/home/stream/nginx/ssl:1000:1000:700"
  "/var/cache/nginx:1000:1000:755"
  "/home/stream/redis/data:1000:1000:700"
)

# Função para criar diretórios e ajustar permissões
setup_directories() {
  for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "Criando diretório: $dir"
      mkdir -p "$dir"
    else
      echo "Diretório já existe: $dir"
    fi
  done
}

# Função para aplicar permissões
apply_permissions() {
  for perm in "${permissions[@]}"; do
    IFS=":" read -r path user group perms <<< "$perm"
    if [ -d "$path" ]; then
      echo "Ajustando permissões para $path: dono=$user, grupo=$group, permissões=$perms"
      chown "$user":"$group" "$path"
      chmod "$perms" "$path"
    else
      echo "Diretório não encontrado para aplicar permissões: $path"
    fi
  done
}

# Executar as funções
setup_directories
apply_permissions

echo "Configuração concluída."