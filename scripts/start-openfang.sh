#!/bin/bash
# ── Démarrage OpenFang (Agent OS en Rust) ────────────────────────
# Dashboard web + API sur http://localhost:4200
# Ref: https://www.openfang.sh/docs/getting-started
# Ref: https://www.openfang.sh/docs/configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/root"

LLAMA_PORT="${LLAMA_PORT:-8081}"
OPENFANG_PORT="${OPENFANG_PORT:-4200}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
OPENFANG_DATA="/root/.openfang"

mkdir -p "${OPENFANG_DATA}"

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/openfang" ]; then
    echo "[openfang] ✗ FATAL : binaire /usr/local/bin/openfang introuvable"
    exit 1
fi

echo "[openfang] Version : $(/usr/local/bin/openfang --version 2>/dev/null || echo 'inconnue')"

# ── Génération config.toml si absent ─────────────────────────────
# OpenFang lit ~/.openfang/config.toml
# On génère une config minimale pointant vers llama-server local
if [ ! -f "${OPENFANG_DATA}/config.toml" ]; then
    echo "[openfang] Génération de la config initiale..."

    # Dériver l'alias modèle du nom de fichier GGUF (même logique que start-llama.sh)
    HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
    MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

    cat > "${OPENFANG_DATA}/config.toml" << EOF
# Généré par TinAI au premier démarrage
# Editer selon https://www.openfang.sh/docs/configuration
dashboard_listen = "0.0.0.0:${OPENFANG_PORT}"
api_listen        = "0.0.0.0:${OPENFANG_PORT}"
api_key           = "${API_KEY}"

[default_model]
provider = "openai"
model    = "${MODEL_ALIAS}"
api_key  = "${API_KEY}"
base_url = "http://localhost:${LLAMA_PORT}/v1"

[memory]
decay_rate = 0.05

[agents.defaults]
model       = "${MODEL_ALIAS}"
temperature = 0.7
max_tokens  = 4096
EOF

    # Canaux : ajouter seulement si les tokens sont définis
    if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
        printf '\n[channels.telegram]\nenabled = true\ntoken   = "%s"\n' \
            "${TELEGRAM_BOT_TOKEN}" >> "${OPENFANG_DATA}/config.toml"
    fi
    if [ -n "${DISCORD_BOT_TOKEN:-}" ]; then
        printf '\n[channels.discord]\nenabled       = true\ntoken         = "%s"\nallowed_users = []\n' \
            "${DISCORD_BOT_TOKEN}" >> "${OPENFANG_DATA}/config.toml"
    fi
    if [ -n "${SLACK_BOT_TOKEN:-}" ]; then
        printf '\n[channels.slack]\nenabled   = true\nbot_token = "%s"\napp_token = "%s"\n' \
            "${SLACK_BOT_TOKEN}" "${SLACK_APP_TOKEN:-}" >> "${OPENFANG_DATA}/config.toml"
    fi

    # Providers externes
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        printf '\n[providers.anthropic]\napi_key_env = "ANTHROPIC_API_KEY"\n' \
            >> "${OPENFANG_DATA}/config.toml"
    fi
    if [ -n "${OPENAI_API_KEY:-}" ]; then
        printf '\n[providers.openai]\napi_key_env = "OPENAI_API_KEY"\n' \
            >> "${OPENFANG_DATA}/config.toml"
    fi
    if [ -n "${GROQ_API_KEY:-}" ]; then
        printf '\n[providers.groq]\napi_key_env = "GROQ_API_KEY"\n' \
            >> "${OPENFANG_DATA}/config.toml"
    fi

    echo "[openfang] ✓ config.toml généré dans ${OPENFANG_DATA}/"
else
    echo "[openfang] ✓ config.toml existant trouvé"
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

# ── Init OpenFang si premier démarrage ────────────────────────────
if [ ! -f "${OPENFANG_DATA}/.initialized" ]; then
    echo "[openfang] Initialisation de l'espace de travail..."
    /usr/local/bin/openfang init --non-interactive 2>/dev/null \
        || echo "[openfang] init ignoré (démarrage direct)"
    touch "${OPENFANG_DATA}/.initialized"
fi

# ── Log des canaux et providers activés ──────────────────────────
echo "[openfang] Dashboard → http://localhost:${OPENFANG_PORT}"
echo "[openfang] API       → http://localhost:${OPENFANG_PORT}/v1/chat/completions"
echo "[openfang] LLM local → http://localhost:${LLAMA_PORT}/v1"
[ -n "${TELEGRAM_BOT_TOKEN:-}" ]  && echo "[openfang] ✓ Canal Telegram"
[ -n "${DISCORD_BOT_TOKEN:-}" ]   && echo "[openfang] ✓ Canal Discord"
[ -n "${SLACK_BOT_TOKEN:-}" ]     && echo "[openfang] ✓ Canal Slack"
[ -n "${ANTHROPIC_API_KEY:-}" ]   && echo "[openfang] ✓ Provider Anthropic"
[ -n "${OPENAI_API_KEY:-}" ]      && echo "[openfang] ✓ Provider OpenAI"
[ -n "${GROQ_API_KEY:-}" ]        && echo "[openfang] ✓ Provider Groq"

# ── Démarrage ─────────────────────────────────────────────────────
exec /usr/local/bin/openfang start
