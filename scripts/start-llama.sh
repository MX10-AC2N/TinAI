#!/bin/bash
# ── Démarrage llama-server ────────────────────────────────────────
# llama-server gère nativement le téléchargement HuggingFace via
# --hf-repo / --hf-file → pas de script de téléchargement custom.
# Ref: https://github.com/ggml-org/llama.cpp/tree/master/tools/server

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

HF_REPO="${LLAMA_HF_REPO:-Qwen/Qwen3-1.7B-GGUF}"
HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
MODEL_PATH="${LLAMA_MODEL_PATH:-/data/models/${HF_FILE}}"
CTX="${LLAMA_CTX_SIZE:-8192}"
THREADS="${LLAMA_THREADS:-4}"
GPU_LAYERS="${LLAMA_GPU_LAYERS:-0}"
PORT="${LLAMA_PORT:-8081}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"

# ── Alias dynamique dérivé du nom de fichier ──────────────────────
# qwen3-1.7b-q5_k_m.gguf               → qwen3-1.7b
# mistral-7b-instruct-v0.2.Q4_K_M.gguf → mistral-7b-instruct-v0.2
MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/llama-server" ]; then
    echo "[llama] ✗ FATAL : /usr/local/bin/llama-server introuvable"
    exit 1
fi

mkdir -p "$(dirname "${MODEL_PATH}")"

# ── Lancement ─────────────────────────────────────────────────────
# Si le modèle est déjà présent → --model direct
# Sinon → --hf-repo + --hf-file (téléchargement natif llama-server)
if [ -f "${MODEL_PATH}" ]; then
    echo "[llama] ✓ Modèle trouvé : ${MODEL_PATH}"
    echo "[llama] Lancement sur :${PORT} | alias=${MODEL_ALIAS} | threads=${THREADS} | ctx=${CTX}"
    exec /usr/local/bin/llama-server \
        --model        "${MODEL_PATH}" \
        --ctx-size     "${CTX}" \
        --threads      "${THREADS}" \
        --n-gpu-layers "${GPU_LAYERS}" \
        --host         0.0.0.0 \
        --port         "${PORT}" \
        --api-key      "${API_KEY}" \
        --alias        "${MODEL_ALIAS}"
else
    echo "[llama] Modèle absent – téléchargement via llama-server natif..."
    echo "[llama] Repo : ${HF_REPO}  Fichier : ${HF_FILE}"
    echo "[llama] Lancement sur :${PORT} | alias=${MODEL_ALIAS} | threads=${THREADS} | ctx=${CTX}"
    exec /usr/local/bin/llama-server \
        --hf-repo      "${HF_REPO}" \
        --hf-file      "${HF_FILE}" \
        --model        "${MODEL_PATH}" \
        --ctx-size     "${CTX}" \
        --threads      "${THREADS}" \
        --n-gpu-layers "${GPU_LAYERS}" \
        --host         0.0.0.0 \
        --port         "${PORT}" \
        --api-key      "${API_KEY}" \
        --alias        "${MODEL_ALIAS}"
fi
