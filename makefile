# TinAI – Makefile
#
#   make           déploiement sans Open WebUI
#   make webui     déploiement avec Open WebUI  
#   make down      arrêt
#   make logs      logs en direct
#   make model     sélecteur de modèle

.PHONY: all deploy webui down logs model monitoring monitoring-down

all: deploy

deploy:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh

webui:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh --profile webui

down:
	docker compose down

monitoring:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh --profile monitoring

monitoring-down:
	docker compose --profile monitoring down

logs:
	docker compose logs -f

model:
	chmod +x scripts/select-model.sh 2>/dev/null || true
	bash scripts/select-model.sh
