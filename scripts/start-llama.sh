#!/bin/bash
# ── Démarrage llama-server ────────────────────────────────────────
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

# ── Alias dynamique dérivé du nom de fichier ──────────────────────
MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/llama-server" ]; then
    echo "[llama] ✗ FATAL : /usr/local/bin/llama-server introuvable"
    exit 1
fi

# ── Détection CPU et optimisations runtime ────────────────────────
CPU_SUMMARY="inconnu"
EXTRA_ARGS="${LLAMA_EXTRA_ARGS:-}"

if [ -x "/usr/local/bin/detect-cpu.sh" ]; then
    CPU_SUMMARY=$(detect-cpu.sh --summary 2>/dev/null || echo "détection échouée")
fi

# Threads automatique si non défini explicitement
if [ "${THREADS}" = "4" ] && [ -f /proc/cpuinfo ]; then
    NPROC=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo)
    # Utilise les cœurs physiques (pas HT) pour l'inférence
    PHYS=$(grep "^cpu cores" /proc/cpuinfo | head -1 | awk '{print $4}')
    if [ -n "${PHYS}" ] && [ "${PHYS}" -gt 0 ] 2>/dev/null; then
        THREADS="${PHYS}"
    else
        THREADS="${NPROC}"
    fi
fi

echo "[llama] ════════════════════════════════════════"
echo "[llama] CPU     : ${CPU_SUMMARY}"
echo "[llama] Threads : ${THREADS} (cœurs physiques)"
echo "[llama] Modèle  : ${MODEL_PATH}"
echo "[llama] Alias   : ${MODEL_ALIAS}"
echo "[llama] Port    : ${PORT} | ctx=${CTX} | gpu_layers=${GPU_LAYERS}"
echo "[llama] ════════════════════════════════════════"

mkdir -p "$(dirname "${MODEL_PATH}")"

# ── Lancement ─────────────────────────────────────────────────────
if [ -f "${MODEL_PATH}" ]; then
    echo "[llama] ✓ Modèle trouvé localement"
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
    echo "[llama] Modèle absent – téléchargement via llama-server natif..."
    echo "[llama] Repo : ${HF_REPO}  Fichier : ${HF_FILE}"
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
        --alias        "${MODEL_ALIAS}" \
        ${EXTRA_ARGS}
fi
