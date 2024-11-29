FROM jellyfin/jellyfin:latest

# Atualiza pacotes e instala os codecs necessários
RUN apt-get update && \
    apt-get install -y jellyfin-ffmpeg7 libavcodec-extra --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*