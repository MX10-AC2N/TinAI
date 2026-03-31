#!/bin/sh
# ══════════════════════════════════════════════════════════════════
#  TinAI – Déploiement whiptail v7 (TOUT optionnel + Hermès wizard)
# ══════════════════════════════════════════════════════════════════
set -eu

# Auto-fix permissions
chmod +x "$(dirname "$0")/deploy.sh" "$(dirname "$0")"/scripts/*.sh 2>/dev/null || true

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'
C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

ok()   { printf "${G}✓ %s${N}\n" "$*"; }
info() { printf "${C}→ %s${N}\n" "$*"; }
warn() { printf "${Y}⚠ %s${N}\n" "$*"; }
die()  { printf "${R}✗ %s${N}\n" "$*" >&2; exit 1; }

# Prérequis
command -v docker >/dev/null 2>&1 || die "docker non trouvé"
docker compose version >/dev/null 2>&1 || die "docker compose non trouvé"
[ -f docker-compose.yml ] || die "Lance ce script depuis le dossier TinAI"

# .env
if [ ! -f .env ]; then
    warn ".env absent — copie depuis .env.example"
    cp .env.example .env || die ".env.example introuvable"
fi

# ── MENU PRINCIPAL WHIPTAIL ─────────────────────────────
PROFILES=""
if [ $# -eq 0 ]; then
    if command -v whiptail >/dev/null 2>&1; then
        CHOICES=$(whiptail --title "TinAI – Menu de déploiement v7" \
            --checklist "\nSélectionne les services à installer :" \
            22 90 14 \
            "llama"      "llama.cpp      → Serveur LLM local + API"          ON \
            "openfang"   "OpenFang       → Agents IA autonomes"              ON \
            "litellm"    "LiteLLM        → Proxy universel OpenAI"           OFF \
            "hermes"     "Hermès Agent   → Agent auto-améliorant (wizard)"   OFF \
            "webui"      "Open WebUI     → Interface chat avancée"           OFF \
            "monitoring" "Monitoring     → Netdata dashboard"                OFF \
            3>&1 1>&2 2>&3)

        for item in $CHOICES; do
            PROFILES="$PROFILES --profile $(echo "$item" | tr -d '"')"
        done

        [ -z "$PROFILES" ] && {
            whiptail --title "Erreur" --msgbox "Aucun service sélectionné.\nAnnulation." 10 60
            exit 1
        }
    else
        warn "whiptail non trouvé → menu texte"
        printf "\n${W}1) llama + OpenFang\n2) Tout\n3) llama seul\n4) OpenFang seul\nChoix : ${N}"
        read -r CHOICE
        case "$CHOICE" in
            1) PROFILES="--profile llama --profile openfang" ;; 
            2) PROFILES="--profile llama --profile openfang --profile litellm --profile hermes --profile webui --profile monitoring" ;; 
            3) PROFILES="--profile llama" ;; 
            4) PROFILES="--profile openfang" ;; 
            *) die "Choix invalide" ;;
        esac
    fi
fi

# Parsing --profile en ligne de commande
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

# ── Banner ────────────────────────────────────────────────────────
printf "\n${W}╔══════════════════════════════════════════════════╗${N}\n"
printf "${W}║           TinAI – Déploiement whiptail v7       ║${N}\n"
printf "${W}╚══════════════════════════════════════════════════╝${N}\n\n"

# ── Déploiement Docker ────────────────────────────────────────────
info "Démarrage des services sélectionnés..."
# shellcheck disable=SC2086
docker compose $PROFILES up -d --build

# Création des dossiers et config LiteLLM
mkdir -p litellm data/hermes data/openfang data/webui models
if [ ! -f litellm/config.yaml ]; then
    cp litellm/config.yaml.example litellm/config.yaml 2>/dev/null || true
    [ ! -f litellm/config.yaml ] && cat > litellm/config.yaml << 'EOF'
model_list:
  - model_name: llama-local
    litellm_params:
      model: openai/llama-local
      api_base: http://llama:8080/v1
      api_key: sk-tinai
EOF
fi

# ── SOUS-MENU MODÈLE llama.cpp (si sélectionné) ───────────────────
if echo "$PROFILES" | grep -q "llama"; then
    printf "\n${C}=== Configuration llama.cpp ===${N}\n"
    if command -v whiptail >/dev/null 2>&1; then
        if whiptail --title "Modèle llama.cpp" --yesno "\nVoulez-vous sélectionner/télécharger un modèle maintenant ?" 12 75; then
            bash "${SCRIPT_DIR}/scripts/select-model.sh"
        else
            info "Tu pourras le faire plus tard avec : make model"
        fi
    fi
fi

# ── SETUP WIZARD HERMÈS AGENT (si sélectionné) ───────────────────
if echo "$PROFILES" | grep -q "hermes"; then
    printf "\n${C}=== Configuration Hermès Agent ===${N}\n"
    HERMES_DATA="$(grep "^HERMES_DATA_DIR=" .env | cut -d'=' -f2 | tr -d '"')"
    mkdir -p "$HERMES_DATA"

    # Vérifie si le wizard a déjà été lancé (fichier .env dans le volume)
    if [ ! -f "$HERMES_DATA/.env" ]; then
        if command -v whiptail >/dev/null 2>&1; then
            if whiptail --title "Hermès Agent – Setup Wizard" \
                --yesno "\nC'est la première fois que tu lances Hermès.\n\nVoulez-vous lancer le wizard officiel de Nous Research maintenant ?\n(Il te demandera tes clés API et configurera tout automatiquement)" 14 80; then
                info "Lancement du setup wizard Hermès (interactif)..."
                docker run -it --rm \ 
                    -v "$HERMES_DATA:/opt/data" \ 
                    nousresearch/hermes-agent
                ok "Setup Hermès terminé !"
            else
                info "Wizard sauté. Tu pourras le lancer plus tard avec : make hermes-wizard"
            fi
        fi
    else
        ok "Hermès Agent déjà configuré (fichier .env trouvé)"
    fi
fi

printf "\n${G}🎉 TinAI est prêt !${N}\n"
printf "Services lancés : ${PROFILES:---aucun--}\n"
printf "\nURLs utiles :\n"
printf "  • llama.cpp     → http://localhost:${PORT_LLAMA:-8081}\n"
printf "  • OpenFang      → http://localhost:${PORT_OPENFANG:-4200}\n"
printf "  • LiteLLM       → http://localhost:${PORT_LITELLM:-4000}\n"
printf "  • Hermès Agent  → http://localhost:${PORT_HERMES:-4201}\n"
printf "  • Open WebUI    → http://localhost:${PORT_WEBUI:-3000}\n"