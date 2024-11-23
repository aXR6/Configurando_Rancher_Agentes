#!/bin/bash

# Verifica se os argumentos foram passados
if [ $# -ne 2 ]; then
    echo "Uso: $0 <diretório_origem> <diretório_destino>"
    exit 1
fi

# Define os diretórios
DIR_ORIGEM="$1"
DIR_DESTINO="$2"

# Verifica se os diretórios existem
if [ ! -d "$DIR_ORIGEM" ]; then
    echo "Erro: O diretório de origem '$DIR_ORIGEM' não existe."
    exit 1
fi

if [ ! -d "$DIR_DESTINO" ]; then
    echo "Erro: O diretório de destino '$DIR_DESTINO' não existe."
    exit 1
fi

# Calcula o tamanho total dos arquivos em bytes
TOTAL_BYTES=$(find "$DIR_ORIGEM" -type f -exec stat -c %s {} + | awk '{sum+=$1} END {printf "%.0f", sum}')
TOTAL_ITENS=$(find "$DIR_ORIGEM" -type f -o -type d | wc -l)

echo "Total de arquivos/pastas: $TOTAL_ITENS"

# Verifica se há arquivos a serem transferidos
if [ -z "$TOTAL_BYTES" ] || [ "$TOTAL_BYTES" -eq 0 ]; then
    echo "Nada a transferir."
    exit 0
fi

# Converte o total de bytes para MB com precisão
TOTAL_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_BYTES / 1024 / 1024}")

echo "Total de dados a serem transferidos: $TOTAL_MB MB"

# Variáveis de progresso
COUNT=0
BYTES_TRANSFERIDOS=0
START_TIME=$(date +%s)

# Função para exibir a barra de progresso
mostrar_progresso() {
    local ATUAL=$1
    local TOTAL=$2
    local BYTES=$3
    local TOTAL_BYTES=$4
    local ARQUIVO_PCT=$5
    local START_TIME=$6

    # Calcula a porcentagem geral
    local PERCENT_GERAL=$((BYTES * 100 / TOTAL_BYTES))
    local BARRA_GERAL=$((PERCENT_GERAL / 2))

    # Calcula o tempo decorrido e a taxa de transferência
    local TEMPO_AGORA=$(date +%s)
    local TEMPO_DECORRIDO=$((TEMPO_AGORA - START_TIME))
    local MB_TRANSFERIDOS=$(awk "BEGIN {printf \"%.2f\", $BYTES / 1024 / 1024}")
    local MB_POR_SEGUNDO=0
    if [ $TEMPO_DECORRIDO -gt 0 ]; then
        MB_POR_SEGUNDO=$(awk "BEGIN {printf \"%.2f\", $BYTES / 1024 / 1024 / $TEMPO_DECORRIDO}")
    fi

    # Exibe a barra de progresso geral e do arquivo atual
    printf "\r[%-50s] %d%% (%d/%d) | %.2f%% arquivo atual | %.2f MB transferidos | %.2f MB/s" \
        "$(printf '#%.0s' $(seq 1 $BARRA_GERAL))" \
        "$PERCENT_GERAL" "$ATUAL" "$TOTAL" "$ARQUIVO_PCT" "$MB_TRANSFERIDOS" "$MB_POR_SEGUNDO"
}

# Função para transferir e exibir progresso
transferir() {
    local ORIGEM="$1"
    local DESTINO="$2"

    while IFS= read -r ITEM; do
        RELATIVO="${ITEM#$DIR_ORIGEM/}"  # Remove o prefixo do diretório de origem
        DESTINO_COMPLETO="$DESTINO/$RELATIVO"

        if [ -d "$ITEM" ]; then
            # Cria o diretório correspondente no destino
            mkdir -p "$DESTINO_COMPLETO"
        else
            # Obtém o tamanho do arquivo
            TAMANHO_ARQUIVO=$(stat -c %s "$ITEM")
            TAMANHO_TRANSFERIDO=0

            # Exibe o nome do arquivo
            TAMANHO_MB=$(awk "BEGIN {printf \"%.2f\", $TAMANHO_ARQUIVO / 1024 / 1024}")
            printf "\nTransferindo: %s (Tamanho: %.2f MB)\n" "$ITEM" "$TAMANHO_MB"

            # Copia o arquivo e monitora o progresso
            while [ $TAMANHO_TRANSFERIDO -lt $TAMANHO_ARQUIVO ]; do
                # Transfere blocos de 1MB
                dd if="$ITEM" of="$DESTINO_COMPLETO" bs=1M seek=$((TAMANHO_TRANSFERIDO / 1048576)) \
                    skip=$((TAMANHO_TRANSFERIDO / 1048576)) count=1 conv=notrunc oflag=append status=none
                TAMANHO_TRANSFERIDO=$((TAMANHO_TRANSFERIDO + 1048576))
                if [ $TAMANHO_TRANSFERIDO -gt $TAMANHO_ARQUIVO ]; then
                    TAMANHO_TRANSFERIDO=$TAMANHO_ARQUIVO
                fi

                PERCENT_ARQUIVO=$(awk "BEGIN {printf \"%.2f\", $TAMANHO_TRANSFERIDO * 100 / $TAMANHO_ARQUIVO}")
                BYTES_TRANSFERIDOS=$((BYTES_TRANSFERIDOS + 1048576))
                mostrar_progresso "$COUNT" "$TOTAL_ITENS" "$BYTES_TRANSFERIDOS" "$TOTAL_BYTES" "$PERCENT_ARQUIVO" "$START_TIME"
            done
        fi

        COUNT=$((COUNT + 1))
    done < <(find "$ORIGEM" -type f -o -type d)
}

# Inicia a transferência
transferir "$DIR_ORIGEM" "$DESTINO"

# Exibe mensagem de conclusão
echo -e "\nTransferência concluída. Total de itens transferidos: $COUNT"

# chmod +x transferencia_de_arquivos.sh
# ./transferencia_de_arquivos.sh /caminho/para/origem /caminho/para/destino

##########################################################################################################################
#
# Total de arquivos/pastas: 1721
# Total de dados a serem transferidos: 1987.40 MB
# Transferindo: /origem/arquivo1.txt (Tamanho: 5.00 MB)
# [##########                                  ] 20% (1/1721) | 50.00% arquivo atual | 50.00 MB transferidos | 5.50 MB/s
#
##########################################################################################################################