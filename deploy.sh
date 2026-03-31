#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Déploiement whiptail v7 (TOUT est optionnel)
# ══════════════════════════════════════════════════════════════════
set -eu

chmod +x "$(dirname "$0")/deploy.sh" "$(dirname "$0")"/scripts/*.sh 2>/dev/null || true

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

SCRIPT_DIR="\( (cd " \)(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ok()   { printf "\( {G}✓ %s \){N}\n" "$*"; }
info() { printf "\( {C}→ %s \){N}\n" "$*"; }
warn() { printf "\( {Y}⚠ %s \){N}\n" "$*"; }
die()  { printf "\( {R}✗ %s \){N}\n" "$*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || die "docker non trouvé"
docker compose version >/dev/null 2>&1 || die "docker compose non trouvé"
[ -f docker-compose.yml ] || die "Lance depuis le dossier TinAI"

if [ ! -f .env ]; then
    warn ".env absent → copie depuis .env.example"
    cp .env.example .env
fi

PROFILES=""

if [ $# -eq 0 ]; then
    if command -v whiptail >/dev/null 2>&1; then
        CHOICES=$(whiptail --title "TinAI – Menu de déploiement v7" \
            --checklist "\nSélectionne les services à installer :" \
            20 85 12 \
            "llama"      "llama.cpp      → Serveur LLM local + API"          ON \
            "openfang"   "OpenFang       → Agents IA autonomes"              ON \
            "webui"      "Open WebUI     → Interface chat avancée"           OFF \
            "monitoring" "Monitoring     → Netdata (dashboard système)"      OFF \
            3>&1 1>&2 2>&3)

        for item in $CHOICES; do
            PROFILES="$PROFILES --profile $(echo "$item" | tr -d '"')"
        done

        if [ -z "$PROFILES" ]; then
            whiptail --title "Erreur" --msgbox "Aucun service sélectionné.\nAnnulation." 10 60
            exit 1
        fi
    else
        warn "whiptail non trouvé → menu texte"
        printf "\n1) llama + OpenFang\n2) llama seul\n3) OpenFang seul\n4) Tout\nChoix : "
        read -r CHOICE
        case "$CHOICE" in
            1) PROFILES="--profile llama --profile openfang" ;;
            2) PROFILES="--profile llama" ;;
            3) PROFILES="--profile openfang" ;;
            4) PROFILES="--profile llama --profile openfang --profile webui --profile monitoring" ;;
            *) die "Choix invalide" ;;
        esac
    fi
fi

# Parsing ligne de commande (rétro-compatibilité)
if [ -z "$PROFILES" ]; then
    PROFILES=""; SKIP_NEXT=0
    for arg in "$@"; do
        if [ "$SKIP_NEXT" = 1 ]; then PROFILES="$PROFILES --profile $arg"; SKIP_NEXT=0
        else case "$arg" in --profile=*) PROFILES="$PROFILES --profile ${arg#--profile=}";; --profile) SKIP_NEXT=1;; esac
        fi
    done
fi

printf "\n\( {W}╔══════════════════════════════════════════════════╗ \){N}\n"
printf "\( {W}║           TinAI – Déploiement whiptail v7       ║ \){N}\n"
printf "\( {W}╚══════════════════════════════════════════════════╝ \){N}\n\n"

info "Démarrage des services sélectionnés..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d --build

# SOUS-MENU MODÈLE → uniquement si llama est coché
if echo "$PROFILES" | grep -q -- "--profile llama"; then
    printf "\n\( {C}=== Configuration llama.cpp === \){N}\n"
    if command -v whiptail >/dev/null 2>&1; then
        if whiptail --title "Modèle llama.cpp" --yesno "\nVoulez-vous sélectionner/télécharger un modèle maintenant ?" 12 75; then
            bash "${SCRIPT_DIR}/scripts/select-model.sh"
        else
            info "Tu pourras le faire plus tard avec : make model"
        fi
    else
        # fallback texte (comme avant)
        MODELS_DIR="$(grep "^MODELS_DIR=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'")"
        MODELS_DIR="${MODELS_DIR:-./models}"
        mkdir -p "$MODELS_DIR"
        if ! find "$MODELS_DIR" -maxdepth 1 -name "*.gguf" | grep -q .; then
            printf "Télécharger un modèle maintenant ? [O/n] : "
            read -r LAUNCH
            [ "\( LAUNCH" != "n" ] && bash " \){SCRIPT_DIR}/scripts/select-model.sh"
        fi
    fi
fi

printf "\n\( {G}🎉 TinAI est prêt ! \){N}\n"
printf "Services lancés : ${PROFILES:---aucun--}\n"