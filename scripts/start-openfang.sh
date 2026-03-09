#!/bin/bash
# ── Démarrage OpenFang (binaire Rust natif) ───────────────────────
# OpenFang est un Agent OS compilé en Rust (~32 MB).
# Web UI disponible sur http://localhost:4200
# Ref: https://github.com/RightNow-AI/openfang

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LLAMA_PORT="${LLAMA_PORT:-8081}"
OPENFANG_PORT="${OPENFANG_PORT:-4200}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
OPENFANG_DATA="${DATA_DIR:-/data}/openfang"

mkdir -p "${OPENFANG_DATA}"

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/openfang" ]; then
    echo "[openfang] ✗ FATAL : binaire /usr/local/bin/openfang introuvable"
    exit 1
fi

echo "[openfang] Version : $(/usr/local/bin/openfang --version 2>/dev/null || echo 'inconnue')"

# ── Init si premier démarrage ─────────────────────────────────────
if [ ! -f "${OPENFANG_DATA}/.initialized" ]; then
    echo "[openfang] Premier démarrage – initialisation..."
    OPENAI_API_BASE="http://localhost:${LLAMA_PORT}/v1" \
    OPENAI_API_KEY="${API_KEY}" \
    /usr/local/bin/openfang init --non-interactive 2>/dev/null \
        || echo "[openfang] init non-interactive non supporté, démarrage direct..."
    touch "${OPENFANG_DATA}/.initialized"
    echo "[openfang] ✓ Initialisation terminée"
fi

# ── Attente llama-server ──────────────────────────────────────────
echo "[openfang] Attente de llama-server sur :${LLAMA_PORT}..."
for i in $(seq 1 60); do
    if curl -sf "http://localhost:${LLAMA_PORT}/health" \
            -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1; then
        echo "[openfang] ✓ llama-server disponible (${i}x5s)"
        break
    fi
    echo "[openfang] ... attente (${i}/60)"
    sleep 5
done

# ── Log des canaux activés ────────────────────────────────────────
[ -n "${TELEGRAM_BOT_TOKEN:-}" ]  && echo "[openfang] ✓ Canal Telegram activé"
[ -n "${DISCORD_BOT_TOKEN:-}" ]   && echo "[openfang] ✓ Canal Discord activé"
[ -n "${SLACK_BOT_TOKEN:-}" ]     && echo "[openfang] ✓ Canal Slack activé"
[ -n "${ANTHROPIC_API_KEY:-}" ]   && echo "[openfang] ✓ Provider Anthropic disponible"
[ -n "${OPENAI_API_KEY:-}" ]      && echo "[openfang] ✓ Provider OpenAI disponible"
[ -n "${GROQ_API_KEY:-}" ]        && echo "[openfang] ✓ Provider Groq disponible"

# ── Démarrage ─────────────────────────────────────────────────────
echo "[openfang] Démarrage sur :${OPENFANG_PORT}..."
echo "[openfang] Web UI  → http://localhost:${OPENFANG_PORT}"
echo "[openfang] API     → http://localhost:${OPENFANG_PORT}/v1/chat/completions"
echo "[openfang] LLM     → http://localhost:${LLAMA_PORT}/v1 (llama-server local)"

exec /usr/local/bin/openfang start \
    --data "${OPENFANG_DATA}" \
    --no-desktop
