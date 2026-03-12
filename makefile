# ══════════════════════════════════════════════════════════════════
#  TinAI – Makefile
#
#  Usage :
#    make          → déploiement standard (sans Open WebUI)
#    make webui    → avec Open WebUI
#    make down     → arrêt
#    make logs     → logs en direct
#    make model    → sélecteur de modèle
# ══════════════════════════════════════════════════════════════════

SHELL := /bin/bash
# Forcer l'exécution depuis le répertoire du Makefile
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all deploy webui down logs model permissions

permissions:
	@chmod +x $(MAKEFILE_DIR)deploy.sh $(MAKEFILE_DIR)scripts/*.sh 2>/dev/null || true

all: deploy

deploy: permissions
	@cd $(MAKEFILE_DIR) && bash deploy.sh

webui: permissions
	@cd $(MAKEFILE_DIR) && bash deploy.sh --profile webui

down:
	@cd $(MAKEFILE_DIR) && docker compose down

logs:
	@cd $(MAKEFILE_DIR) && docker compose logs -f

model: permissions
	@cd $(MAKEFILE_DIR) && bash scripts/select-model.sh
