#!/bin/bash
# ── Démarrage OpenFang (Agent OS en Rust) ────────────────────────
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/root"

LLAMA_HOST="${LLAMA_HOST:-llama}"      # nom du service docker compose
LLAMA_PORT="${LLAMA_PORT:-8081}"
OPENFANG_PORT="${OPENFANG_PORT:-4200}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
OPENFANG_DATA="/root/.openfang"

mkdir -p "${OPENFANG_DATA}"

if [ ! -x "/usr/local/bin/openfang" ]; then
    echo "[openfang] ✗ FATAL : binaire /usr/local/bin/openfang introuvable"
    exit 1
fi

echo "[openfang] Version : $(/usr/local/bin/openfang --version 2>/dev/null || echo 'inconnue')"

# ── Génération config.toml si absent ─────────────────────────────
if [ ! -f "${OPENFANG_DATA}/config.toml" ]; then
    echo "[openfang] Génération de la config initiale..."

    HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
    MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

    cat > "${OPENFANG_DATA}/config.toml" << TOML
# Généré par TinAI au premier démarrage
dashboard_listen = "0.0.0.0:${OPENFANG_PORT}"
api_listen        = "0.0.0.0:${OPENFANG_PORT}"
api_key           = "${API_KEY}"

[default_model]
provider = "openai"
model    = "${MODEL_ALIAS}"
api_key  = "${API_KEY}"
base_url = "http://${LLAMA_HOST}:${LLAMA_PORT}/v1"

[memory]
decay_rate = 0.05

[agents.defaults]
model       = "${MODEL_ALIAS}"
temperature = 0.7
max_tokens  = 4096
TOML

    # Canaux optionnels
    [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && printf '\n[channels.telegram]\nenabled = true\ntoken   = "%s"\n' \
        "${TELEGRAM_BOT_TOKEN}" >> "${OPENFANG_DATA}/config.toml"
    [ -n "${DISCORD_BOT_TOKEN:-}" ] && printf '\n[channels.discord]\nenabled       = true\ntoken         = "%s"\nallowed_users = []\n' \
        "${DISCORD_BOT_TOKEN}" >> "${OPENFANG_DATA}/config.toml"
    [ -n "${SLACK_BOT_TOKEN:-}" ] && printf '\n[channels.slack]\nenabled   = true\nbot_token = "%s"\napp_token = "%s"\n' \
        "${SLACK_BOT_TOKEN}" "${SLACK_APP_TOKEN:-}" >> "${OPENFANG_DATA}/config.toml"
    [ -n "${ANTHROPIC_API_KEY:-}" ] && printf '\n[providers.anthropic]\napi_key_env = "ANTHROPIC_API_KEY"\n' \
        >> "${OPENFANG_DATA}/config.toml"
    [ -n "${OPENAI_API_KEY:-}" ] && printf '\n[providers.openai]\napi_key_env = "OPENAI_API_KEY"\n' \
        >> "${OPENFANG_DATA}/config.toml"
    [ -n "${GROQ_API_KEY:-}" ] && printf '\n[providers.groq]\napi_key_env = "GROQ_API_KEY"\n' \
        >> "${OPENFANG_DATA}/config.toml"

    echo "[openfang] ✓ config.toml généré (LLM → http://${LLAMA_HOST}:${LLAMA_PORT}/v1)"
else
    echo "[openfang] ✓ config.toml existant trouvé"
fi

echo "[openfang] Dashboard → http://localhost:${OPENFANG_PORT}"
echo "[openfang] LLM local → http://${LLAMA_HOST}:${LLAMA_PORT}/v1"
[ -n "${TELEGRAM_BOT_TOKEN:-}" ]  && echo "[openfang] ✓ Canal Telegram"
[ -n "${DISCORD_BOT_TOKEN:-}" ]   && echo "[openfang] ✓ Canal Discord"
[ -n "${SLACK_BOT_TOKEN:-}" ]     && echo "[openfang] ✓ Canal Slack"

# ── Init si premier démarrage ──────────────────────────────────────
if [ ! -f "${OPENFANG_DATA}/.initialized" ]; then
    /usr/local/bin/openfang init --non-interactive 2>/dev/null \
        || echo "[openfang] init ignoré (démarrage direct)"
    touch "${OPENFANG_DATA}/.initialized"
fi

exec /usr/local/bin/openfang start
