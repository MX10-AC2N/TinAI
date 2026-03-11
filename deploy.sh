#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Script de déploiement
#  Usage : ./deploy.sh [--profile webui]
#  1. Lance docker compose up -d
#  2. Si aucun modèle GGUF trouvé → propose select-model.sh
# ══════════════════════════════════════════════════════════════════
set -eu

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ok()   { printf "${G}✓ %s${N}\n" "$*"; }
info() { printf "${C}→ %s${N}\n" "$*"; }
warn() { printf "${Y}⚠ %s${N}\n" "$*"; }
die()  { printf "${R}✗ %s${N}\n" "$*" >&2; exit 1; }

# ── Récupérer le répertoire des modèles depuis .env ───────────────
get_models_dir() {
    if [ -f .env ]; then
        MDIR=$(grep "^MODELS_DIR=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    fi
    MDIR="${MDIR:-./models}"
    # Résoudre le chemin relatif
    case "$MDIR" in
        /*) echo "$MDIR" ;;
        *)  echo "${SCRIPT_DIR}/${MDIR#./}" ;;
    esac
}

# ── Vérifier si un modèle GGUF est présent ────────────────────────
has_model() {
    MDIR="$1"
    [ -d "$MDIR" ] && find "$MDIR" -maxdepth 1 -name "*.gguf" | grep -q . 2>/dev/null
}

# ─────────────────────────────────────────────────────────────────
printf "\n${W}"
printf "╔══════════════════════════════════════════════════╗\n"
printf "║              TinAI – Déploiement                ║\n"
printf "╚══════════════════════════════════════════════════╝\n"
printf "${N}\n"

# ── Vérifications préalables ──────────────────────────────────────
command -v docker >/dev/null 2>&1  || die "docker non trouvé"
docker compose version >/dev/null 2>&1 || die "docker compose non trouvé"

[ -f docker-compose.yml ] || die "docker-compose.yml introuvable (lancer depuis le dossier TinAI)"

if [ ! -f .env ]; then
    warn ".env absent — copie depuis .env.example"
    cp .env.example .env || die ".env.example introuvable"
    ok ".env créé — édite-le si besoin avant de continuer"
fi

# ── Docker compose up ─────────────────────────────────────────────
PROFILES=""
for arg in "$@"; do
    case "$arg" in
        --profile) shift; PROFILES="--profile $1" ;;
        --profile=*) PROFILES="--profile ${arg#--profile=}" ;;
    esac
done

info "Démarrage des conteneurs..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d
printf "\n"

docker compose ps
printf "\n"

# ── Vérifier la présence d'un modèle GGUF ────────────────────────
MODELS_DIR=$(get_models_dir)
mkdir -p "$MODELS_DIR"

if has_model "$MODELS_DIR"; then
    MODELS=$(find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | sort)
    ok "Modèle(s) trouvé(s) dans ${MODELS_DIR} :"
    echo "$MODELS" | while read -r f; do
        SIZE=$(ls -lh "$f" | awk '{print $5}')
        printf "  • %s  (%s)\n" "$(basename "$f")" "$SIZE"
    done
    printf "\n"
    printf "${C}→ llama-server va démarrer avec le modèle configuré dans .env${N}\n"
    printf "${C}→ Pour changer de modèle : ./scripts/select-model.sh${N}\n\n"
else
    printf "${Y}"
    printf "╔══════════════════════════════════════════════════╗\n"
    printf "║   Aucun modèle GGUF trouvé dans %-16s║\n" "${MODELS_DIR}/"
    printf "║   llama-server attend un modèle pour démarrer.  ║\n"
    printf "╚══════════════════════════════════════════════════╝\n"
    printf "${N}\n"

    printf "Lancer le sélecteur de modèle maintenant ? [O/n] : "
    read -r LAUNCH
    case "$LAUNCH" in
        [nN])
            printf "\n"
            warn "Pas de modèle — llama-server restera inactif."
            printf "Lance quand tu veux : ${W}./scripts/select-model.sh${N}\n\n"
            ;;
        *)
            printf "\n"
            exec ./scripts/select-model.sh
            ;;
    esac
fi
