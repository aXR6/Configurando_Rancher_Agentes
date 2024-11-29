# Usar a imagem oficial como base
FROM jellyfin/jellyfin:latest

# Atualizar pacotes e instalar o jellyfin-ffmpeg versão 7
RUN apt-get update && apt-get install -y \
    jellyfin-ffmpeg7 libavcodec-extra \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Definir a variável de ambiente para usar o ffmpeg correto
ENV JELLYFIN_FFMPEG=/usr/lib/jellyfin-ffmpeg/ffmpeg

# Expor as portas usadas pelo Jellyfin
EXPOSE 8096 8920

# Configurar o ponto de entrada (mantém o padrão da imagem oficial)
CMD ["/jellyfin/jellyfin.dll"]