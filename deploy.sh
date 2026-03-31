#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Point d'entrée unique (version whiptail ultra-avancée)
#  Usage : ./deploy.sh          → menu graphique whiptail
#          ./deploy.sh --profile webui --profile monitoring
# ══════════════════════════════════════════════════════════════════
set -eu

# Auto-fix permissions
chmod +x "$(dirname "$0")/deploy.sh" "$(dirname "$0")"/scripts/*.sh 2>/dev/null || true

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

SCRIPT_DIR="\( (cd " \)(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ok()   { printf "\( {G}✓ %s \){N}\n" "$*"; }
info() { printf "\( {C}→ %s \){N}\n" "$*"; }
warn() { printf "\( {Y}⚠ %s \){N}\n" "$*"; }
die()  { printf "\( {R}✗ %s \){N}\n" "$*" >&2; exit 1; }

# Prérequis
command -v docker >/dev/null 2>&1 || die "docker non trouvé"
docker compose version >/dev/null 2>&1 || die "docker compose non trouvé"
[ -f docker-compose.yml ] || die "Lance ce script depuis le dossier TinAI"

# .env
if [ ! -f .env ]; then
    warn ".env absent — copie depuis .env.example"
    cp .env.example .env || die ".env.example introuvable"
fi

# ── MENU WHIPTAIL (si aucun argument) ─────────────────────────────
if [ $# -eq 0 ]; then
    if command -v whiptail >/dev/null 2>&1; then
        # Menu whiptail ultra-beau avec checkboxes
        CHOICES=$(whiptail --title "TinAI – Menu de déploiement" \
            --checklist "\nChoisis les composants optionnels à installer\n(Base : llama.cpp + OpenFang toujours inclus)" \
            18 78 10 \
            "webui"      "Open WebUI     → Interface chat avancée"      OFF \
            "monitoring" "Monitoring     → Netdata (dashboard système)" OFF \
            3>&1 1>&2 2>&3)

        # Nettoyage et construction des --profile
        PROFILES=""
        for item in $CHOICES; do
            PROFILES="$PROFILES --profile $(echo "$item" | tr -d '"')"
        done
    else
        # Fallback menu texte (si whiptail absent)
        warn "whiptail non trouvé → menu texte classique"
        printf "\n\( {W}Quelle stack veux-tu installer ? \){N}\n\n"
        printf "  1) Base seulement\n"
        printf "  2) Base + Open WebUI\n"
        printf "  3) Base + Monitoring\n"
        printf "  4) Tout (Base + WebUI + Monitoring)\n\n"
        printf "${W}Ton choix [1-4] : ${N}"
        read -r CHOICE

        case "$CHOICE" in
            1) PROFILES="" ;;
            2) PROFILES="--profile webui" ;;
            3) PROFILES="--profile monitoring" ;;
            4) PROFILES="--profile webui --profile monitoring" ;;
            *) die "Choix invalide" ;;
        esac

        # Suggestion d'installation whiptail
        printf "\n${C}Astuce : pour un menu encore plus beau, installe whiptail :\n"
        printf "   sudo apt install whiptail   (Debian/Ubuntu)\n${N}"
    fi
    printf "\n"
fi

# ── Parsing des --profile (si fournis en ligne de commande) ───────
if [ -z "${PROFILES:-}" ]; then
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
fi

# ── Banner ────────────────────────────────────────────────────────
printf "\n${W}"
printf "╔══════════════════════════════════════════════════╗\n"
printf "║           TinAI – Déploiement whiptail v6       ║\n"
printf "╚══════════════════════════════════════════════════╝${N}\n\n"

# ── Lancement Docker Compose ──────────────────────────────────────
info "Démarrage des conteneurs..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d --build

# ── Vérification modèle (identique à ton script actuel) ───────────
MODELS_DIR="$(grep "^MODELS_DIR=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'")"
MODELS_DIR="${MODELS_DIR:-./models}"
case "\( MODELS_DIR" in /*) ;; *) MODELS_DIR=" \){SCRIPT_DIR}/${MODELS_DIR#./}" ;; esac
mkdir -p "$MODELS_DIR"

if find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | grep -q . 2>/dev/null; then
    ok "Modèle(s) présent(s) :"
    find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | sort | while read -r f; do
        SIZE=$(ls -lh "$f" | awk '{print $5}')
        printf "  • %s  (%s)\n" "$(basename "$f")" "$SIZE"
    done
    printf "\n${C}Pour changer de modèle : \( {W}make model \){N}\n\n"
else
    printf "\n${Y}╔══════════════════════════════════════════════════╗\n"
    printf "║   Aucun modèle GGUF détecté                     ║\n"
    printf "╚══════════════════════════════════════════════════╝${N}\n\n"
    printf "Télécharger un modèle maintenant ? [O/n] : "
    read -r LAUNCH
    case "$LAUNCH" in
        [nN]) warn "Sans modèle, llama-server reste en attente." ;;
        *) bash "${SCRIPT_DIR}/scripts/select-model.sh" ;;
    esac
fi