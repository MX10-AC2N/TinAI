#!/bin/bash
# ── Démarrage Open WebUI ──────────────────────────────────────────
set -euo pipefail

LLAMA_PORT="${LLAMA_PORT:-8081}"
WEBUI_PORT="${WEBUI_PORT:-3000}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
SECRET_KEY="${WEBUI_SECRET_KEY:-tinai-secret-change-me}"
DATA_DIR="${DATA_DIR:-/data}"

echo "[webui] Attente de llama-server sur le port ${LLAMA_PORT}..."

# Attendre que llama-server soit prêt (max 3 min)
for i in $(seq 1 36); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[webui] ✓ llama-server disponible"
        break
    fi
    echo "[webui] ... attente (${i}/36)"
    sleep 5
done

echo "[webui] Démarrage Open WebUI sur le port ${WEBUI_PORT}..."

export OPENAI_API_BASE_URL="http://localhost:${LLAMA_PORT}/v1"
export OPENAI_API_KEY="${API_KEY}"
export WEBUI_SECRET_KEY="${SECRET_KEY}"
export DATA_DIR="${DATA_DIR}/webui"
export PORT="${WEBUI_PORT}"
export HOST="0.0.0.0"
# Désactive l'auth au premier démarrage (optionnel)
export WEBUI_AUTH="False"

mkdir -p "${DATA_DIR}/webui"

# Lancement selon la méthode disponible
if command -v open-webui >/dev/null 2>&1; then
    exec open-webui serve --host 0.0.0.0 --port "${WEBUI_PORT}"
elif [ -f /opt/open-webui/backend/main.py ]; then
    cd /opt/open-webui
    exec python3 -m uvicorn backend.main:app \
        --host 0.0.0.0 \
        --port "${WEBUI_PORT}" \
        --workers 1
else
    echo "[webui] ✗ Open WebUI introuvable"
    exit 1
fi
