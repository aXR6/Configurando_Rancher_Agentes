### Pasta contendo o projeto.

### Pasta cluster/
### Entendendo (Pasta Cluster/old/)
* Projeto antigo;

### Entendendo (Pasta Cluster/yaml - Atualizados/)
* Projeto atualizado com os códigos para subir o projeto Transmission;

### Pasta Docker/
* Na pasta transmission/ contém o projeto para rodar apenas em 1 maquina local.

### Mais sobre:
Relatório do Projeto de Streaming
Título: Projeto de Streaming com Traefik e Jellyfin
Data: 23/12/2024

Descrição Geral
O projeto utiliza uma infraestrutura baseada em contêineres para fornecer um serviço de streaming de mídia robusto e otimizado. As principais tecnologias são:

Traefik: Gerencia o proxy reverso, roteamento de tráfego e segurança HTTPS.
Jellyfin: Servidor de mídia para streaming local e remoto.
Docker Compose: Orquestra os serviços e suas configurações.
O foco principal do projeto é garantir:

Eficiência no cache para melhorar o desempenho.
Otimização de streaming para oferecer uma experiência fluida aos usuários.
Configuração de Cache
O projeto implementa estratégias de cache tanto no Traefik quanto no Jellyfin:

Cache no Traefik
Cabeçalhos HTTP otimizados para cache:

No middleware jellyfin-cache, os cabeçalhos Cache-Control foram configurados como:
public, max-age=3600, stale-while-revalidate=600
Permite que recursos menos sensíveis (como capas de mídia) sejam armazenados em cache por uma hora.
Para conteúdos dinâmicos, os cabeçalhos foram configurados com no-store, must-revalidate para evitar o cache de dados sensíveis.
Compressão Dinâmica:

O middleware de compressão foi habilitado para reduzir o tamanho das respostas HTTP, melhorando a velocidade de carregamento sem impactar negativamente a qualidade do streaming.
Cache no Jellyfin
Diretório de Cache em tmpfs:

O cache temporário do Jellyfin foi configurado para utilizar tmpfs com 20 GB alocados. Essa abordagem garante:
Alta performance no armazenamento temporário.
Limpeza automática ao reiniciar, evitando acúmulo desnecessário de dados.
Gerenciamento de Cache Automático:

O parâmetro JELLYFIN_CACHEMAXAGE=3600 define que arquivos em cache têm validade de 1 hora, garantindo um equilíbrio entre performance e consumo de recursos.
Configuração de Streaming
Streaming no Traefik
Protocolo HTTP/2:

HTTP/2 foi habilitado para conexões HTTPS, otimizando múltiplas transmissões simultâneas através do mesmo canal.
Aceitação de Ranges:

O cabeçalho Accept-Ranges: bytes foi ativado para permitir o carregamento parcial de conteúdos, fundamental para streaming de mídia.
Limitação de Taxa (Rate Limiting):

O middleware rate-limit foi configurado para evitar sobrecargas de tráfego e garantir uma experiência estável para todos os usuários:
Média de 100 requisições por segundo.
Explosão máxima de 50 requisições adicionais permitidas em curto prazo.
Streaming no Jellyfin
Transcodificação de Hardware:

A aceleração de hardware foi habilitada com JELLYFIN_HWACCEL=true, reduzindo a carga no CPU durante a transcodificação.
O Jellyfin utiliza dispositivos de hardware dedicados para otimizar a conversão de formatos de mídia em tempo real.
Segmentação de Mídia:

A configuração JELLYFIN_STREAMSEGMENTSIZE=6 define que os segmentos de vídeo têm 6 segundos de duração, reduzindo o tempo de buffering e melhorando a experiência de streaming.
Downmix de Áudio:

O parâmetro JELLYFIN_AUDIOMIXDOWN=stereo garante que o áudio seja convertido para estéreo em conexões de baixa largura de banda, sem comprometer a compatibilidade.
Principais Benefícios
Desempenho Melhorado:

O uso de tmpfs e cache configurado no Traefik garante tempos de resposta rápidos e menor latência no streaming.
A compressão diminui o consumo de banda sem impacto perceptível na qualidade.
Experiência de Usuário Fluida:

Segmentação curta de mídia e suporte a Accept-Ranges permitem uma reprodução contínua, mesmo em redes instáveis.
Segurança e Eficiência:

Os cabeçalhos de cache foram ajustados para evitar armazenamento indevido de informações sensíveis.
O uso de HTTP/2 e TLS reforça a segurança das conexões.
Otimização de Recursos:

A aceleração de hardware alivia a carga do servidor e aumenta a eficiência da transcodificação.
Possíveis Melhorias Futuras
Monitoramento de Desempenho:

Adicionar métricas no Traefik e Jellyfin para monitorar consumo de recursos e taxa de cache.
Usar ferramentas como Grafana ou Prometheus para obter insights em tempo real.
Cache Distribuído:

Implementar um sistema de cache distribuído (ex.: Redis ou Memcached) para armazenar metadados e diminuir a carga no servidor principal.
Streaming Adaptativo:

Habilitar suporte completo a HLS (HTTP Live Streaming) no Jellyfin para ajustar a qualidade do vídeo automaticamente com base na largura de banda disponível.
Conclusão
O projeto foi configurado com práticas recomendadas para cache e streaming, garantindo alto desempenho e uma experiência de usuário otimizada. Com as melhorias implementadas, a infraestrutura está preparada para lidar com múltiplas conexões simultâneas de forma eficiente e segura.

Para aprimoramentos futuros, investir em monitoramento e cache distribuído trará ainda mais robustez à solução.
```

Thalles Canela - TSC
Canal no YouTube: https://www.youtube.com/c/aXR6CyberSecurity
Perfil no Github: https://github.com/aXR6/
Fórum: https://forum.universodoti.com.br/
```