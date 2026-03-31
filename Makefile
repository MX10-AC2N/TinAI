.PHONY: all deploy llama openfang webui monitoring full down logs model

all: deploy

deploy:
	chmod +x deploy.sh scripts/*.sh 2>/dev/null || true
	bash deploy.sh

llama:      ; bash deploy.sh --profile llama
openfang:   ; bash deploy.sh --profile openfang
webui:      ; bash deploy.sh --profile webui
monitoring: ; bash deploy.sh --profile monitoring
full:       ; bash deploy.sh --profile llama --profile openfang --profile webui --profile monitoring

down:
	docker compose --profile llama --profile openfang --profile webui --profile monitoring down

logs:       ; docker compose logs -f
model:      ; bash scripts/select-model.sh