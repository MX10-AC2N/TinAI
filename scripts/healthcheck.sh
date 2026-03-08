#!/bin/bash
# ── Healthcheck TinAI ─────────────────────────────────────────────
LLAMA_PORT="${LLAMA_PORT:-8081}"
WEBUI_PORT="${WEBUI_PORT:-3000}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"

# llama-server doit répondre
curl -sf "http://localhost:${LLAMA_PORT}/health" \
    -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1 || exit 1

# Open WebUI doit répondre
curl -sf "http://localhost:${WEBUI_PORT}/" >/dev/null 2>&1 || exit 1

exit 0
