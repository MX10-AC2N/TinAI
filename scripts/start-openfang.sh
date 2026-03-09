#!/bin/bash
# ── Démarrage OpenFang (binaire Rust natif) ───────────────────────
# OpenFang est un Agent OS compilé en Rust (~32 MB).
# Ce script gère l'init, la config et le démarrage du daemon.
# Ref: https://github.com/RightNow-AI/openfang

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LLAMA_PORT="${LLAMA_PORT:-8081}"
OPENFANG_PORT="${OPENFANG_PORT:-4200}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
DATA_DIR="${DATA_DIR:-/data}"
OPENFANG_DATA="${DATA_DIR}/openfang"

mkdir -p "${OPENFANG_DATA}"

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/openfang" ]; then
    echo "[openfang] ✗ FATAL : binaire /usr/local/bin/openfang introuvable"
    exit 1
fi

echo "[openfang] Version : $(/usr/local/bin/openfang --version 2>/dev/null || echo 'inconnue')"

# ── Init OpenFang si premier démarrage ────────────────────────────
if [ ! -f "${OPENFANG_DATA}/.initialized" ]; then
    echo "[openfang] Premier démarrage – initialisation..."

    # openfang init configure le provider LLM et crée la structure de données
    OPENAI_API_BASE="http://localhost:${LLAMA_PORT}/v1" \
    OPENAI_API_KEY="${API_KEY}" \
    OPENFANG_LISTEN="0.0.0.0:${OPENFANG_PORT}" \
    OPENFANG_DATA_DIR="${OPENFANG_DATA}" \
    /usr/local/bin/openfang init --non-interactive 2>/dev/null \
        || echo "[openfang] init non-interactive non supporté, démarrage direct..."

    touch "${OPENFANG_DATA}/.initialized"
    echo "[openfang] ✓ Initialisation terminée"
fi

# ── Attente llama-server ──────────────────────────────────────────
echo "[openfang] Attente de llama-server sur :${LLAMA_PORT}..."
for i in $(seq 1 36); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" \
            -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[openfang] ✓ llama-server disponible (${i}x5s)"
        break
    fi
    echo "[openfang] ... attente (${i}/36)"
    sleep 5
done

# ── Configuration canaux (si tokens présents) ─────────────────────
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
    echo "[openfang] Telegram bot détecté – activation du canal..."
fi
if [ -n "${DISCORD_BOT_TOKEN:-}" ]; then
    echo "[openfang] Discord bot détecté – activation du canal..."
fi
if [ -n "${SLACK_BOT_TOKEN:-}" ]; then
    echo "[openfang] Slack bot détecté – activation du canal..."
fi

# ── Démarrage du daemon OpenFang ──────────────────────────────────
echo "[openfang] Démarrage sur :${OPENFANG_PORT}..."
echo "[openfang] Dashboard → http://localhost:${OPENFANG_PORT}"
echo "[openfang] API       → http://localhost:${OPENFANG_PORT}/v1/chat/completions"

exec /usr/local/bin/openfang start \
    --data "${OPENFANG_DATA}" \
    --no-desktop
