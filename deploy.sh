#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Point d'entrée unique pour le déploiement
#  Remplace : docker compose up -d
#  Usage    : ./deploy.sh [--profile webui]
# ══════════════════════════════════════════════════════════════════
set -eu

# ── Auto-fix permissions (au cas où git n'a pas préservé +x) ──────
chmod +x "$(dirname "$0")/deploy.sh"          "$(dirname "$0")"/scripts/*.sh 2>/dev/null || true


R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ok()   { printf "${G}✓ %s${N}\n" "$*"; }
info() { printf "${C}→ %s${N}\n" "$*"; }
warn() { printf "${Y}⚠ %s${N}\n" "$*"; }
die()  { printf "${R}✗ %s${N}\n" "$*" >&2; exit 1; }

# ── Prérequis ─────────────────────────────────────────────────────
command -v docker >/dev/null 2>&1 || die "docker non trouvé"
docker compose version >/dev/null 2>&1 || die "docker compose non trouvé"
[ -f docker-compose.yml ] || die "Lance ce script depuis le dossier TinAI"

# ── .env ──────────────────────────────────────────────────────────
if [ ! -f .env ]; then
    warn ".env absent — copie depuis .env.example"
    cp .env.example .env || die ".env.example introuvable"
fi

# ── Profils optionnels (cumulables : --profile webui --profile monitoring) ─
PROFILES=""
SKIP_NEXT=0
for arg in "$@"; do
    if [ "$SKIP_NEXT" = "1" ]; then
        PROFILES="$PROFILES --profile $arg"
        SKIP_NEXT=0
    else
        case "$arg" in
            --profile=*) PROFILES="$PROFILES --profile ${arg#--profile=}" ;;
            --profile)   SKIP_NEXT=1 ;;
        esac
    fi
done

# ── Banner ────────────────────────────────────────────────────────
printf "\n${W}"
printf "╔══════════════════════════════════════════════════╗\n"
printf "║              TinAI – Déploiement v5             ║\n"
printf "╚══════════════════════════════════════════════════╝\n"
printf "${N}\n"

# ── Docker compose up ─────────────────────────────────────────────
info "Démarrage des conteneurs..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d --build
printf "\n"

# ── Vérifier la présence d'un modèle ─────────────────────────────
MODELS_DIR="$(grep "^MODELS_DIR=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'")"
MODELS_DIR="${MODELS_DIR:-./models}"
case "$MODELS_DIR" in /*) ;; *) MODELS_DIR="${SCRIPT_DIR}/${MODELS_DIR#./}" ;; esac
mkdir -p "$MODELS_DIR"

if find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | grep -q . 2>/dev/null; then
    # Modèle présent
    ok "Modèle(s) présent(s) :"
    find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | sort | while read -r f; do
        SIZE=$(ls -lh "$f" | awk '{print $5}')
        printf "  • %s  (%s)\n" "$(basename "$f")" "$SIZE"
    done
    printf "\n${C}Pour changer de modèle : ${W}make model${N}\n\n"
else
    # Aucun modèle — lancer le sélecteur
    printf "\n${Y}"
    printf "╔══════════════════════════════════════════════════╗\n"
    printf "║   Aucun modèle GGUF dans %-22s  ║\n" "${MODELS_DIR}/"
    printf "║   llama-server attend un modèle.                ║\n"
    printf "╚══════════════════════════════════════════════════╝\n"
    printf "${N}\n"

    printf "Télécharger un modèle maintenant ? [O/n] : "
    read -r LAUNCH
    case "$LAUNCH" in
        [nN])
            warn "Sans modèle, llama-server reste en attente."
            printf "${C}Lance quand tu veux : ${W}./scripts/select-model.sh${N}\n\n"
            ;;
        *)
            printf "\n"
            bash "${SCRIPT_DIR}/scripts/select-model.sh"
            ;;
    esac
fi
