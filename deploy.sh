#!/bin/sh
# TinAI – Déploiement whiptail v7 (TOUT optionnel + LiteLLM + Hermès)
set -eu

# ... (le début du script reste identique : couleurs, prérequis, .env)

PROFILES=""

if [ $# -eq 0 ]; then
    if command -v whiptail >/dev/null 2>&1; then
        CHOICES=$(whiptail --title "TinAI – Menu de déploiement v7" \
            --checklist "\nSélectionne les services à installer :" \
            22 90 14 \
            "llama"      "llama.cpp      → Serveur LLM local + API"          ON \
            "openfang"   "OpenFang       → Agents IA autonomes"              ON \
            "litellm"    "LiteLLM        → Proxy universel OpenAI"           OFF \
            "hermes"     "Hermès Agent   → Agent auto-améliorant"            OFF \
            "webui"      "Open WebUI     → Interface chat avancée"           OFF \
            "monitoring" "Monitoring     → Netdata dashboard"                OFF \
            3>&1 1>&2 2>&3)

        for item in $CHOICES; do
            PROFILES="$PROFILES --profile $(echo "$item" | tr -d '"')"
        done

        [ -z "$PROFILES" ] && { whiptail --title "Erreur" --msgbox "Aucun service sélectionné." 10 60; exit 1; }
    else
        # fallback texte (identique à avant)
        echo "1) llama + OpenFang"; echo "2) Tout"; etc.   # (tu peux garder ton ancien fallback)
    fi
fi

# Parsing --profile (ligne de commande) → identique à avant

# Banner + docker compose up
info "Démarrage des services sélectionnés..."
docker compose $PROFILES up -d --build

# Création automatique des dossiers et fichiers de config
mkdir -p litellm data/hermes data/openfang data/webui models
if [ ! -f litellm/config.yaml ]; then
    cat > litellm/config.yaml << EOF
model_list:
  - model_name: llama-local
    litellm_params:
      model: openai/llama-local
      api_base: http://llama:8080/v1
      api_key: sk-tinai
EOF
fi

# Sous-menu modèle uniquement si llama est sélectionné
if echo "$PROFILES" | grep -q "llama"; then
    if command -v whiptail >/dev/null 2>&1; then
        whiptail --title "Modèle llama.cpp" --yesno "\nVoulez-vous sélectionner/télécharger un modèle maintenant ?" 12 75 && bash scripts/select-model.sh
    fi
fi

printf "\n\( {G}🎉 TinAI est prêt ! \){N}\n"