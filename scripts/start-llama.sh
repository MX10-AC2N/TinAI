#!/bin/bash
# ── Démarrage llama-server ────────────────────────────────────────
# set -euo pipefail supprimé : supervisord relancerait sur moindre erreur.

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

MODEL_PATH="${LLAMA_MODEL_PATH:-/data/models/model.gguf}"
HF_REPO="${LLAMA_HF_REPO:-Qwen/Qwen3-1.7B-GGUF}"
HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
CTX="${LLAMA_CTX_SIZE:-8192}"
THREADS="${LLAMA_THREADS:-4}"
GPU_LAYERS="${LLAMA_GPU_LAYERS:-0}"
PORT="${LLAMA_PORT:-8081}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"

# ── Alias dynamique dérivé du nom de fichier ──────────────────────
# qwen3-1.7b-q5_k_m.gguf            → qwen3-1.7b
# mistral-7b-instruct-v0.2.Q4_K_M.gguf → mistral-7b-instruct-v0.2
MODEL_ALIAS=$(echo "${HF_FILE}" | sed 's/[.-][qQ][0-9][^.]*\.gguf$//' | sed 's/\.gguf$//')

echo "[llama] Démarrage llama-server..."
echo "[llama] Modèle  : ${MODEL_PATH}"
echo "[llama] Alias   : ${MODEL_ALIAS}"

# ── Vérification du binaire ───────────────────────────────────────
if [ ! -x "/usr/local/bin/llama-server" ]; then
    echo "[llama] ✗ FATAL : /usr/local/bin/llama-server introuvable"
    exit 1
fi

# ── Téléchargement automatique si absent ─────────────────────────
if [ ! -f "${MODEL_PATH}" ]; then
    echo "[llama] Modèle absent – téléchargement depuis HuggingFace..."
    echo "[llama] Repo    : ${HF_REPO}"
    echo "[llama] Fichier : ${HF_FILE}"

    mkdir -p "$(dirname "${MODEL_PATH}")"
    DOWNLOAD_OK=0

    # Tentative 1 : huggingface_hub (Python)
    if command -v python3 >/dev/null 2>&1; then
        echo "[llama] Tentative via huggingface_hub (Python)..."
        python3 - <<EOF 2>&1 && DOWNLOAD_OK=1
from huggingface_hub import hf_hub_download
import shutil, os, sys
try:
    path = hf_hub_download(
        repo_id="${HF_REPO}",
        filename="${HF_FILE}",
        local_dir="/data/models",
        local_dir_use_symlinks=False
    )
    expected = "${MODEL_PATH}"
    if path != expected and os.path.exists(path):
        shutil.move(path, expected)
        print(f"[llama] Modèle déplacé vers {expected}")
    else:
        print(f"[llama] Modèle disponible : {path}")
except Exception as e:
    print(f"[llama] huggingface_hub échoué : {e}", file=sys.stderr)
    sys.exit(1)
EOF
    fi

    # Tentative 2 : wget
    if [ "${DOWNLOAD_OK}" -eq 0 ] && command -v wget >/dev/null 2>&1; then
        echo "[llama] Fallback wget..."
        HF_URL="https://huggingface.co/${HF_REPO}/resolve/main/${HF_FILE}"
        if wget --retry-connrefused --tries=3 -q --show-progress \
               -O "${MODEL_PATH}.tmp" "${HF_URL}"; then
            mv "${MODEL_PATH}.tmp" "${MODEL_PATH}"
            DOWNLOAD_OK=1
        else
            rm -f "${MODEL_PATH}.tmp"
            echo "[llama] ✗ wget échoué"
        fi
    fi

    # Tentative 3 : curl
    if [ "${DOWNLOAD_OK}" -eq 0 ] && command -v curl >/dev/null 2>&1; then
        echo "[llama] Fallback curl..."
        HF_URL="https://huggingface.co/${HF_REPO}/resolve/main/${HF_FILE}"
        if curl --retry 3 -fL --progress-bar \
                -o "${MODEL_PATH}.tmp" "${HF_URL}"; then
            mv "${MODEL_PATH}.tmp" "${MODEL_PATH}"
            DOWNLOAD_OK=1
        else
            rm -f "${MODEL_PATH}.tmp"
            echo "[llama] ✗ curl échoué"
        fi
    fi

    if [ "${DOWNLOAD_OK}" -eq 0 ]; then
        echo "[llama] ✗ FATAL : impossible de télécharger le modèle."
        echo "[llama]   → Monte ton fichier .gguf dans /data/models/ et relance."
        echo "[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:${MODEL_PATH}"
        exit 1
    fi

    echo "[llama] ✓ Modèle prêt : ${MODEL_PATH}"
else
    echo "[llama] ✓ Modèle trouvé : ${MODEL_PATH}"
fi

# ── Lancement ─────────────────────────────────────────────────────
echo "[llama] Lancement sur :${PORT} | threads=${THREADS} | ctx=${CTX}"
exec /usr/local/bin/llama-server \
    --model        "${MODEL_PATH}" \
    --ctx-size     "${CTX}" \
    --threads      "${THREADS}" \
    --n-gpu-layers "${GPU_LAYERS}" \
    --host         0.0.0.0 \
    --port         "${PORT}" \
    --api-key      "${API_KEY}" \
    --alias        "${MODEL_ALIAS}"
