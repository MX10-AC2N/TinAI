#!/bin/bash
# ── Démarrage Open WebUI ──────────────────────────────────────────
# Doc: https://docs.openwebui.com
# Port interne : 8080 (mappé sur WEBUI_PORT=3000 par docker-compose)
# Data dir     : /app/backend/data (convention Open WebUI)

set -euo pipefail

LLAMA_PORT="${LLAMA_PORT:-8081}"
WEBUI_PORT="${WEBUI_PORT:-3000}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
SECRET_KEY="${WEBUI_SECRET_KEY:-tinai-secret-change-me}"

echo "[webui] Attente de llama-server sur :${LLAMA_PORT}..."

# Attendre que llama-server soit prêt (max 5 min — inclut le téléchargement du modèle)
for i in $(seq 1 60); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" \
            -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[webui] ✓ llama-server disponible (${i}x5s)"
        break
    fi
    echo "[webui] ... attente llama-server (${i}/60)"
    sleep 5
done

echo "[webui] Démarrage Open WebUI sur :${WEBUI_PORT}..."
mkdir -p /app/backend/data

# ── Variables Open WebUI (doc officielle) ────────────────────────
# OPENAI_API_BASE_URL : endpoint llama-server local
# OPENAI_API_KEY      : clé pour llama-server (= TINAI_API_KEY)
# DATA_DIR            : /app/backend/data (convention Open WebUI)
# PORT                : port interne (8080 par défaut Open WebUI,
#                       on le force à WEBUI_PORT pour supervisord)
# WEBUI_AUTH          : True = auth activée (défaut sécurisé)
export OPENAI_API_BASE_URL="http://localhost:${LLAMA_PORT}/v1"
export OPENAI_API_KEY="${API_KEY}"
export WEBUI_SECRET_KEY="${SECRET_KEY}"
export DATA_DIR="/app/backend/data"
export PORT="${WEBUI_PORT}"
export HOST="0.0.0.0"
export WEBUI_AUTH="${WEBUI_AUTH:-True}"
# Désactiver la télémétrie
export SCARF_NO_ANALYTICS=true
export DO_NOT_TRACK=true
export ANONYMIZED_TELEMETRY=false

echo "[webui] URL   → http://localhost:${WEBUI_PORT}"
echo "[webui] LLM   → http://localhost:${LLAMA_PORT}/v1"
echo "[webui] Auth  → ${WEBUI_AUTH}"

exec open-webui serve --host 0.0.0.0 --port "${WEBUI_PORT}"
