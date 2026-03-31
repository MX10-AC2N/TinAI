# ══════════════════════════════════════════════════════════════════
#  TinAI v7 – Makefile (menu whiptail + tout à la carte)
# ══════════════════════════════════════════════════════════════════

.PHONY: all deploy full llama openfang litellm hermes webui monitoring down logs model hermes-wizard

all: deploy

deploy:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh

# Targets rapides (power users)
full:      ; bash deploy.sh --profile llama --profile openfang --profile litellm --profile hermes --profile webui --profile monitoring
llama:     ; bash deploy.sh --profile llama
openfang:  ; bash deploy.sh --profile openfang
litellm:   ; bash deploy.sh --profile litellm
hermes:    ; bash deploy.sh --profile hermes
webui:     ; bash deploy.sh --profile webui
monitoring:; bash deploy.sh --profile monitoring

# Commandes de gestion
down:
	docker compose --profile llama --profile openfang --profile litellm --profile hermes --profile webui --profile monitoring down

logs:
	docker compose logs -f

model:
	bash scripts/select-model.sh

# Wizard Hermès (lance uniquement le setup interactif)
hermes-wizard:
	docker run -it --rm \
		-v ./data/hermes:/opt/data \
		nousresearch/hermes-agent