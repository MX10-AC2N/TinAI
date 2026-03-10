#!/bin/bash
# ── Healthcheck TinAI (conteneur backend) ────────────────────────
# Stratégie : openfang (toujours up) rend le conteneur healthy,
# ce qui permet à Open WebUI de démarrer même sans modèle GGUF.
# llama-server est intentionnellement exclu : il est FATAL en CI
# (pas de modèle), ce qui bloquerait le depends_on du service webui.
OPENFANG_PORT="${OPENFANG_PORT:-4200}"

# openfang doit répondre (obligatoire)
curl -sf "http://localhost:${OPENFANG_PORT}/" >/dev/null 2>&1 || exit 1

exit 0
