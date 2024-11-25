import redis
import requests
from flask import Flask, jsonify

app = Flask(__name__)

# Configurações
REDIS_HOST = "redis"
REDIS_PORT = 6379
TRANSMISSION_URL = "http://transmission:9091/transmission/rpc"

# Conexão com Redis
redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

@app.route('/cache/torrents', methods=['GET'])
def get_cached_torrents():
    cached_torrents = redis_client.get("torrent_list")
    if cached_torrents:
        return jsonify({"source": "cache", "data": cached_torrents})
    
    response = requests.get(TRANSMISSION_URL)
    if response.status_code == 200:
        torrent_list = response.json()
        redis_client.setex("torrent_list", 3600, str(torrent_list))  # Cache por 1 hora
        return jsonify({"source": "api", "data": torrent_list})
    return jsonify({"error": "Failed to fetch torrents"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)