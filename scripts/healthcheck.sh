#!/bin/bash
# ── Healthcheck TinAI (conteneur backend) ────────────────────────
# Vérifie llama-server uniquement.
# Open WebUI a son propre healthcheck dans son conteneur.
LLAMA_PORT="${LLAMA_PORT:-8081}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"

curl -sf "http://localhost:${LLAMA_PORT}/health" \
    -H "Authorization: Bearer ${API_KEY}" >/dev/null 2>&1 || exit 1

exit 0
