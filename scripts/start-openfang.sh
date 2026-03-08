#!/bin/bash
# ── Démarrage OpenFang ────────────────────────────────────────────
set -euo pipefail

LLAMA_PORT="${LLAMA_PORT:-8081}"
OPENFANG_PORT="${OPENFANG_PORT:-4200}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
CONFIG_FILE="/data/openfang/openfang.toml"
DATA_DIR="${DATA_DIR:-/data}"

mkdir -p "${DATA_DIR}/openfang"

# ── Génération de la config si absente ────────────────────────────
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "[openfang] Génération de la configuration..."
    cat > "${CONFIG_FILE}" <<TOML
[server]
host = "0.0.0.0"
port = ${OPENFANG_PORT}

[llm]
base_url = "http://localhost:${LLAMA_PORT}/v1"
api_key  = "${API_KEY}"
model    = "qwen3-1.7b"

[agents]
dir = "/data/openfang/agents"
TOML
    echo "[openfang] ✓ Config générée : ${CONFIG_FILE}"
fi

echo "[openfang] Attente de llama-server..."
for i in $(seq 1 24); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[openfang] ✓ llama-server disponible"
        break
    fi
    sleep 5
done

echo "[openfang] Démarrage sur le port ${OPENFANG_PORT}..."

if command -v openfang >/dev/null 2>&1; then
    exec openfang serve --config "${CONFIG_FILE}"
elif python3 -c "import openfang" 2>/dev/null; then
    exec python3 -m openfang serve --config "${CONFIG_FILE}"
else
    echo "[openfang] ⚠ OpenFang non installé – service désactivé"
    # Ne pas faire échouer le conteneur si openfang est absent
    sleep infinity
fi
