#!/bin/sh
# llama-server gère nativement le téléchargement HuggingFace via
# --hf-repo / --hf-file → pas de script de téléchargement custom.
# detect-cpu.sh détecte les capacités CPU au runtime pour optimiser.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

HF_REPO="${LLAMA_HF_REPO:-Qwen/Qwen3-1.7B-GGUF}"
HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
MODEL_PATH="${LLAMA_MODEL_PATH:-/data/models/${HF_FILE}}"
CTX="${LLAMA_CTX_SIZE:-8192}"
THREADS="${LLAMA_THREADS:-4}"
GPU_LAYERS="${LLAMA_GPU_LAYERS:-0}"
PORT="${LLAMA_PORT:-8081}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"
EXTRA_ARGS="${LLAMA_EXTRA_ARGS:-}"

# ── Alias dynamique dérivé du nom de fichier ──────────────────────
MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/llama-server" ]; then
    echo "[llama] ✗ FATAL : /usr/local/bin/llama-server introuvable"
    exit 1
fi

# ── Profil CPU ───────────────────────────────────────────────────
if [ -x "/usr/local/bin/detect-cpu.sh" ]; then
    echo "[llama] CPU     : $(detect-cpu.sh --summary)"
fi
echo "[llama] Threads : ${THREADS} (cœurs physiques)"
echo "[llama] Modèle  : ${MODEL_PATH}"
echo "[llama] Alias   : ${MODEL_ALIAS}"
echo "[llama] Port    : ${PORT} | ctx=${CTX} | gpu_layers=${GPU_LAYERS}"
echo "[llama] ════════════════════════════════════════"

# ── Lancement ────────────────────────────────────────────────────
if [ -f "${MODEL_PATH}" ]; then
    # Modèle déjà présent → démarrage direct
    echo "[llama] Modèle trouvé : ${MODEL_PATH}"
    exec /usr/local/bin/llama-server \
        --model        "${MODEL_PATH}" \
        --ctx-size     "${CTX}" \
        --threads      "${THREADS}" \
        --n-gpu-layers "${GPU_LAYERS}" \
        --host         0.0.0.0 \
        --port         "${PORT}" \
        --api-key      "${API_KEY}" \
        --alias        "${MODEL_ALIAS}" \
        ${EXTRA_ARGS}
else
    # Modèle absent → téléchargement via llama-server natif
    # IMPORTANT : ne PAS passer --model quand le fichier n'existe pas encore,
    # sinon llama-server quitte immédiatement (fichier introuvable).
    # Avec --hf-repo + --hf-file seuls, llama-server télécharge puis démarre.
    mkdir -p "$(dirname "${MODEL_PATH}")"
    echo "[llama] Modèle absent – téléchargement via llama-server natif..."
    echo "[llama] Repo : ${HF_REPO}  Fichier : ${HF_FILE}"
    exec /usr/local/bin/llama-server \
        --hf-repo      "${HF_REPO}" \
        --hf-file      "${HF_FILE}" \
        --ctx-size     "${CTX}" \
        --threads      "${THREADS}" \
        --n-gpu-layers "${GPU_LAYERS}" \
        --host         0.0.0.0 \
        --port         "${PORT}" \
        --api-key      "${API_KEY}" \
        --alias        "${MODEL_ALIAS}" \
        ${EXTRA_ARGS}
fi
