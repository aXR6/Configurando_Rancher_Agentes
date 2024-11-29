FROM jellyfin/jellyfin:latest

# Atualiza pacotes e instala o jellyfin-ffmpeg e codecs adicionais
RUN apt-get update && \
    apt-get install -y jellyfin-ffmpeg libavcodec-extra --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*