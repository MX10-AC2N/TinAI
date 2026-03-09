#!/bin/bash
# ── Démarrage Open CoreUI (backend Rust, ~60 MB) ──────────────────
# Remplace Open WebUI (Python, ~800 MB) par un binaire Rust léger.
# Web UI disponible sur http://localhost:3000
# Ref: https://github.com/xxnuo/open-coreui

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LLAMA_PORT="${LLAMA_PORT:-8081}"
WEBUI_PORT="${WEBUI_PORT:-3000}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
SECRET_KEY="${WEBUI_SECRET_KEY:-tinai-secret-change-me}"
COREUI_DATA="${DATA_DIR:-/data}/coreui"

mkdir -p "${COREUI_DATA}"

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/open-coreui" ]; then
    echo "[coreui] ✗ FATAL : binaire /usr/local/bin/open-coreui introuvable"
    exit 1
fi

echo "[coreui] Version : $(/usr/local/bin/open-coreui --version 2>/dev/null || echo 'inconnue')"

# ── Attente llama-server (inclut le téléchargement du modèle) ─────
echo "[coreui] Attente de llama-server sur :${LLAMA_PORT}..."
for i in $(seq 1 60); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" \
            -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[coreui] ✓ llama-server disponible (${i}x5s)"
        break
    fi
    echo "[coreui] ... attente (${i}/60)"
    sleep 5
done

echo "[coreui] Démarrage Open CoreUI sur :${WEBUI_PORT}..."
echo "[coreui] Web UI → http://localhost:${WEBUI_PORT}"

# Open CoreUI hérite des variables d'env Open WebUI (même nommage)
export OPENAI_API_BASE_URL="http://localhost:${LLAMA_PORT}/v1"
export OPENAI_API_KEY="${API_KEY}"
export WEBUI_SECRET_KEY="${SECRET_KEY}"
export DATA_DIR="${COREUI_DATA}"
export HOST="0.0.0.0"
export PORT="${WEBUI_PORT}"
export WEBUI_AUTH="${WEBUI_AUTH:-True}"

exec /usr/local/bin/open-coreui serve \
    --host 0.0.0.0 \
    --port "${WEBUI_PORT}"
