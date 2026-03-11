#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Entrypoint llama-server
#  Détecte l'absence de modèle GGUF et guide l'utilisateur
#  avant de lancer llama-server.
#  Monté en volume dans le conteneur ghcr.io/ggml-org/llama.cpp:server
# ══════════════════════════════════════════════════════════════════
set -eu

MODELS_DIR="${MODELS_DIR:-/models}"
HF_REPO="${LLAMA_HF_REPO:-Qwen/Qwen3-1.7B-GGUF}"
HF_FILE="${LLAMA_HF_FILE:-Qwen3-1.7B-Q5_K_M.gguf}"
MODEL_PATH="${MODELS_DIR}/${HF_FILE}"

W='\033[1;37m'; Y='\033[0;33m'; G='\033[0;32m'; R='\033[0;31m'; N='\033[0m'

log()  { printf "[llama-entrypoint] %s\n" "$*"; }
warn() { printf "${Y}[llama-entrypoint] ⚠ %s${N}\n" "$*"; }
ok()   { printf "${G}[llama-entrypoint] ✓ %s${N}\n" "$*"; }

# ── Modèle présent → démarrage direct ────────────────────────────
if [ -f "$MODEL_PATH" ]; then
    ok "Modèle trouvé : $MODEL_PATH"
    exec /usr/local/bin/llama-server "$@"
fi

# ── Aucun .gguf dans le volume → instruction claire ───────────────
GGUF_COUNT=$(find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" 2>/dev/null | wc -l)

if [ "$GGUF_COUNT" -gt 0 ]; then
    # Il y a des .gguf mais pas celui configuré dans .env
    FOUND=$(find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | head -5)
    warn "Modèle configuré introuvable : $HF_FILE"
    warn "Fichiers présents dans $MODELS_DIR :"
    echo "$FOUND" | while read -r f; do
        log "  • $(basename "$f")"
    done
    warn "→ Vérifie LLAMA_HF_FILE dans ton .env"
    warn "→ Ou lance : ./scripts/select-model.sh"
    # Attendre au lieu de crasher pour éviter les redémarrages supervisord
    log "En attente... (relancer après correction du .env)"
    while true; do
        sleep 30
        [ -f "$MODEL_PATH" ] && break
        # Vérifier si un nouveau .gguf vient d'apparaître
        NEW=$(find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" -newer "$0" 2>/dev/null | head -1)
        [ -n "$NEW" ] && break
    done
    ok "Modèle détecté — démarrage..."
    exec /usr/local/bin/llama-server "$@"
fi

# ── Dossier models/ vide ─────────────────────────────────────────
printf "\n${Y}"
printf "╔══════════════════════════════════════════════════════════════╗\n"
printf "║   Aucun modèle GGUF trouvé dans %-28s║\n" "${MODELS_DIR}/"
printf "╠══════════════════════════════════════════════════════════════╣\n"
printf "║   Depuis le dossier TinAI sur la machine hôte, lance :      ║\n"
printf "║                                                              ║\n"
printf "║     ./scripts/select-model.sh                               ║\n"
printf "║                                                              ║\n"
printf "║   Le script télécharge le modèle et redémarre ce            ║\n"
printf "║   conteneur automatiquement.                                 ║\n"
printf "╚══════════════════════════════════════════════════════════════╝\n"
printf "${N}\n"
log "Modèle attendu : $MODEL_PATH"
log "Repo configuré : $HF_REPO"
log "Fichier configuré : $HF_FILE"
printf "\n"

# Boucle d'attente — le conteneur reste UP (pas de crash)
# select-model.sh appellera "docker compose restart llama" une fois le modèle prêt
log "En attente du modèle... (vérifie toutes les 30s)"
while true; do
    sleep 30
    if find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | grep -q .; then
        ok "Modèle détecté dans $MODELS_DIR — démarrage de llama-server..."
        # Prendre le premier .gguf trouvé si le fichier exact n'est pas là
        if [ ! -f "$MODEL_PATH" ]; then
            ACTUAL=$(find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | head -1)
            warn "Fichier exact '$HF_FILE' absent — utilisation de : $(basename "$ACTUAL")"
            MODEL_PATH="$ACTUAL"
        fi
        break
    fi
    log "Toujours en attente... (lance ./scripts/select-model.sh)"
done

exec /usr/local/bin/llama-server "$@"
