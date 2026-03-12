# TinAI – Makefile
#
#   make                    déploiement standard
#   make webui              + Open WebUI
#   make monitoring         + Netdata
#   make webui-monitoring   + Open WebUI + Netdata
#   make down               arrêt
#   make logs               logs en direct
#   make model              changer de modèle

.PHONY: all deploy webui monitoring webui-monitoring down monitoring-down logs model

all: deploy

deploy:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh

webui:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh --profile webui

monitoring:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh --profile monitoring

webui-monitoring:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh --profile webui --profile monitoring

down:
	docker compose --profile webui --profile monitoring down

monitoring-down:
	docker compose --profile webui --profile monitoring down

logs:
	docker compose logs -f

model:
	chmod +x scripts/select-model.sh 2>/dev/null || true
	bash scripts/select-model.sh
