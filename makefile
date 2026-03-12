# ══════════════════════════════════════════════════════════════════
#  TinAI – Makefile
#  Remplace docker compose up -d
#
#  Usage :
#    make          → déploiement standard
#    make webui    → avec Open WebUI
#    make down     → arrêt
#    make logs     → logs en direct
#    make model    → sélecteur de modèle
# ══════════════════════════════════════════════════════════════════

.PHONY: all deploy webui down logs model permissions

# Corriger les permissions au début de chaque cible
permissions:
	@chmod +x deploy.sh scripts/*.sh 2>/dev/null || true

all: deploy

deploy: permissions
	@bash deploy.sh

webui: permissions
	@bash deploy.sh --profile webui

down:
	docker compose down

logs:
	docker compose logs -f

model: permissions
	@bash scripts/select-model.sh
