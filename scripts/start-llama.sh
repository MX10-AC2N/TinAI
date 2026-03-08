#!/bin/bash
# ── Démarrage llama-server ────────────────────────────────────────
set -euo pipefail

MODEL_PATH="${LLAMA_MODEL_PATH:-/data/models/qwen3-1.7b.gguf}"
HF_REPO="${LLAMA_HF_REPO:-Qwen/Qwen3-1.7B-GGUF}"
HF_FILE="${LLAMA_HF_FILE:-qwen3-1.7b-q5_k_m.gguf}"
CTX="${LLAMA_CTX_SIZE:-8192}"
THREADS="${LLAMA_THREADS:-4}"
GPU_LAYERS="${LLAMA_GPU_LAYERS:-0}"
PORT="${LLAMA_PORT:-8081}"
API_KEY="${TINAI_API_KEY:-sk-tinai}"

echo "[llama] Démarrage llama-server..."
echo "[llama] Modèle attendu : ${MODEL_PATH}"

# ── Téléchargement automatique du modèle si absent ────────────────
if [ ! -f "${MODEL_PATH}" ]; then
    echo "[llama] Modèle absent – téléchargement depuis HuggingFace..."
    echo "[llama] Repo  : ${HF_REPO}"
    echo "[llama] Fichier : ${HF_FILE}"

    mkdir -p "$(dirname "${MODEL_PATH}")"

    # Tentative avec huggingface_hub (Python)
    if python3 - <<EOF 2>/dev/null
from huggingface_hub import hf_hub_download
import shutil, os
path = hf_hub_download(
    repo_id="${HF_REPO}",
    filename="${HF_FILE}",
    local_dir="/data/models",
    local_dir_use_symlinks=False
)
# Renommer au nom attendu si différent
expected = "${MODEL_PATH}"
if path != expected and os.path.exists(path):
    shutil.move(path, expected)
    print(f"[llama] Modèle déplacé vers {expected}")
else:
    print(f"[llama] Modèle disponible : {path}")
EOF
    then
        echo "[llama] ✓ Téléchargement Python OK"
    else
        # Fallback wget via URL HuggingFace directe
        echo "[llama] Fallback wget..."
        HF_URL="https://huggingface.co/${HF_REPO}/resolve/main/${HF_FILE}"
        wget -q --show-progress -O "${MODEL_PATH}" "${HF_URL}" || {
            echo "[llama] ✗ Échec du téléchargement"
            echo "[llama] Monte ton modèle dans /data/models/ et relance."
            exit 1
        }
    fi
    echo "[llama] ✓ Modèle prêt : ${MODEL_PATH}"
fi

# ── Lancement llama-server ────────────────────────────────────────
echo "[llama] Lancement sur le port ${PORT}..."
exec /usr/local/bin/llama-server \
    --model "${MODEL_PATH}" \
    --ctx-size "${CTX}" \
    --threads "${THREADS}" \
    --n-gpu-layers "${GPU_LAYERS}" \
    --host 0.0.0.0 \
    --port "${PORT}" \
    --api-key "${API_KEY}" \
    --alias qwen3-1.7b \
    --log-disable
