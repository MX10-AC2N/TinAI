#!/bin/bash
# ── Healthcheck TinAI (conteneur backend) ────────────────────────
# Teste l'endpoint public d'openfang : GET /api/health → {"version":"x.y.z"}
# Source : https://github.com/RightNow-AI/openfang (CLAUDE.md + issue #44)
#
# Pourquoi openfang et pas llama-server ?
#   llama-server est FATAL en CI (pas de modèle GGUF) → le conteneur
#   resterait unhealthy pour toujours et bloquerait le démarrage de webui.
#   openfang démarre toujours (~16s) et expose /api/health sans auth.
OPENFANG_PORT="${OPENFANG_PORT:-4200}"

curl -sf "http://localhost:${OPENFANG_PORT}/api/health" >/dev/null 2>&1 || exit 1

exit 0
