#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Déploiement avec gum v8 (moderne & beau)
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

if [ ! -f .env ]; then
    warn ".env absent — copie depuis .env.example"
    cp .env.example .env || die ".env.example introuvable"
fi

# Vérification gum
if ! command -v gum >/dev/null 2>&1; then
    warn "gum n'est pas installé."
    echo "Installe-le avec :"
    echo "   sudo apt install gum -y"
    exit 1
fi

# ── MENU PRINCIPAL AVEC GUM (multi-sélection) ───────────────────
PROFILES=""
if [ $# -eq 0 ]; then
    echo
    gum style --bold --foreground 212 "TinAI – Menu de déploiement v8"
    echo

    SELECTED=$(gum choose \
        --no-limit \
        --header "Sélectionne les services à installer (Espace pour cocher, Entrée pour valider)" \
        "llama      → Serveur LLM local + API" \
        "openfang   → Agents IA autonomes" \
        "litellm    → Proxy universel OpenAI" \
        "hermes     → Hermès Agent (avec wizard)" \
        "webui      → Open WebUI (interface chat)" \
        "monitoring → Netdata dashboard" )

    if [ -z "$SELECTED" ]; then
        die "Aucun service sélectionné. Annulation."
    fi

    # Conversion en --profile
    for item in $SELECTED; do
        case "$item" in
            *llama*)      PROFILES="$PROFILES --profile llama" ;;
            *openfang*)   PROFILES="$PROFILES --profile openfang" ;;
            *litellm*)    PROFILES="$PROFILES --profile litellm" ;;
            *hermes*)     PROFILES="$PROFILES --profile hermes" ;;
            *webui*)      PROFILES="$PROFILES --profile webui" ;;
            *monitoring*) PROFILES="$PROFILES --profile monitoring" ;;
        esac
    done
fi

# Parsing --profile en ligne de commande (rétro-compatibilité)
if [ -z "$PROFILES" ]; then
    PROFILES=""; SKIP_NEXT=0
    for arg in "$@"; do
        if [ "$SKIP_NEXT" = 1 ]; then
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

# Banner
printf "\n\( {W}╔══════════════════════════════════════════════════╗ \){N}\n"
printf "\( {W}║           TinAI – Déploiement gum v8            ║ \){N}\n"
printf "\( {W}╚══════════════════════════════════════════════════╝ \){N}\n\n"

info "Démarrage des services sélectionnés..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d --build

# Création dossiers et config LiteLLM
mkdir -p litellm data/hermes data/openfang data/webui models
if [ ! -f litellm/config.yaml ]; then
    cat > litellm/config.yaml << 'EOF'
model_list:
  - model_name: llama-local
    litellm_params:
      model: openai/llama-local
      api_base: http://llama:8080/v1
      api_key: sk-tinai
EOF
fi

# Sous-menu modèle llama.cpp
if echo "$PROFILES" | grep -q "llama"; then
    printf "\n\( {C}=== Configuration llama.cpp === \){N}\n"
    if gum confirm "Voulez-vous sélectionner/télécharger un modèle maintenant ?"; then
        bash "${SCRIPT_DIR}/scripts/select-model.sh"
    else
        info "Tu pourras le faire plus tard avec : make model"
    fi
fi

# Wizard Hermès
if echo "$PROFILES" | grep -q "hermes"; then
    printf "\n\( {C}=== Configuration Hermès Agent === \){N}\n"
    HERMES_DATA="\( {SCRIPT_DIR}/ \)(grep "^HERMES_DATA_DIR=" .env | cut -d'=' -f2 | tr -d '"')"
    mkdir -p "$HERMES_DATA"
    if [ ! -f "$HERMES_DATA/.env" ]; then
        if gum confirm "C'est la première fois que tu lances Hermès.\nVoulez-vous lancer le setup wizard maintenant ?"; then
            info "Lancement du setup wizard Hermès..."
            docker run -it --rm -v "$HERMES_DATA:/opt/data" nousresearch/hermes-agent
            ok "Setup Hermès terminé !"
        else
            info "Wizard sauté. Tu pourras le lancer plus tard avec : make hermes-wizard"
        fi
    fi
fi

printf "\n\( {G}🎉 TinAI est prêt ! \){N}\n"
printf "Services lancés : ${PROFILES:---aucun--}\n"