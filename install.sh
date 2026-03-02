#!/bin/bash
set -e

echo "🚀 TinAI – Tiny AI Dev Assistant"
echo "================================="

# Installation de gum (menu beau) si absent
if ! command -v gum &> /dev/null; then
    echo "📦 Installation de gum..."
    curl -fsSL https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz -o gum.tar.gz
    tar -xzf gum.tar.gz && sudo mv gum /usr/local/bin/ && rm gum.tar.gz
fi

# Menu multi-sélection ultra-beau
echo "👇 Coche les composants que tu veux (espace = cocher / entrée = valider) :"
CHOICES=$(gum choose --no-limit \
    "llama-server (base obligatoire)" \
    "Open WebUI (frontend riche + RAG)" \
    "Code-Server + Continue.dev (VS Code web)" \
    "Aider (pair programming autonome)" \
    "OpenFang (agents autonomes 24/7)" \
    "LanceDB RAG (mémoire persistante des projets)" \
    "llama-swap (switch modèles à chaud)" \
    "Caddy Reverse Proxy + Filebrowser (URLs propres)")

# Création du projet
mkdir -p TinAI && cd TinAI
mkdir -p models projects

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
EOF

# === BASE OBLIGATOIRE : llama-server ===
cat >> docker-compose.yml << 'BASE'
  tinai-llama:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-llama
    ports: ["8081:8081"]
    volumes: ["./models:/models"]
    command: >
      -hf bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --model-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --port 8081 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja --alias qwen-coder-3b
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 5.5g
BASE

# === SERVICES CONDITIONNELS ===
if echo "$CHOICES" | grep -q "Open WebUI"; then
    cat >> docker-compose.yml << 'WEBUI'
  tinai-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: tinai-webui
    ports: ["3000:8080"]
    volumes: ["open-webui-data:/app/backend/data"]
    environment:
      - OPENAI_API_BASE_URL=http://tinai-llama:8081/v1
      - OPENAI_API_KEY=sk-123456789
    depends_on: [tinai-llama]
    restart: unless-stopped
WEBUI
fi

if echo "$CHOICES" | grep -q "Code-Server"; then
    cat >> docker-compose.yml << 'CODE'
  tinai-code:
    image: ghcr.io/coder/code-server:latest
    container_name: tinai-code
    ports: ["8080:8080"]
    volumes: ["./projects:/home/coder/project", "code-data:/home/coder/.local/share/code-server"]
    environment:
      - PASSWORD=changezmoi123
    entrypoint: /bin/sh -c "
      code-server --install-extension Continue.continue &&
      mkdir -p /home/coder/.continue &&
      cat > /home/coder/.continue/config.json << 'JSON'
{
  \"models\": [{
    \"title\": \"TinAI-Qwen3B\",
    \"provider\": \"openai\",
    \"model\": \"qwen-coder-3b\",
    \"apiBase\": \"http://tinai-llama:8081/v1\",
    \"apiKey\": \"sk-123456789\",
    \"roles\": [\"chat\",\"edit\",\"apply\",\"autocomplete\"]
  }],
  \"tabAutocompleteModel\": { \"title\": \"TinAI-Auto\", \"provider\": \"openai\", \"model\": \"qwen-coder-3b\", \"apiBase\": \"http://tinai-llama:8081/v1\", \"apiKey\": \"sk-123456789\" }
}
JSON
      && /usr/bin/entrypoint.sh"
    restart: unless-stopped
CODE
fi

if echo "$CHOICES" | grep -q "Aider"; then
    cat >> docker-compose.yml << 'AIDER'
  tinai-aider:
    image: paulgauthier/aider
    container_name: tinai-aider
    volumes: ["./projects:/app", "/var/run/docker.sock:/var/run/docker.sock"]
    environment:
      - OPENAI_API_BASE=http://tinai-llama:8081/v1
      - OPENAI_API_KEY=sk-123456789
      - AIDER_MODEL=qwen-coder-3b
    depends_on: [tinai-llama]
    restart: unless-stopped
AIDER
fi

if echo "$CHOICES" | grep -q "OpenFang"; then
    cat >> docker-compose.yml << 'FANG'
  tinai-openfang:
    image: ghcr.io/openfang/openfang:latest
    container_name: tinai-openfang
    ports: ["4200:4200"]
    environment:
      - OPENAI_BASE_URL=http://tinai-llama:8081/v1
      - OPENAI_API_KEY=sk-123456789
    depends_on: [tinai-llama]
    restart: unless-stopped
FANG
fi

if echo "$CHOICES" | grep -q "LanceDB"; then
    cat >> docker-compose.yml << 'LANCEDB'
  tinai-lancedb:
    image: lancedb/lancedb:latest
    container_name: tinai-lancedb
    ports: ["8082:8082"]
    volumes: ["lancedb-data:/data"]
    restart: unless-stopped
LANCEDB
fi

if echo "$CHOICES" | grep -q "llama-swap"; then
    cat >> docker-compose.yml << 'SWAP'
  tinai-swap:
    image: ghcr.io/llama-swap/llama-swap:latest
    container_name: tinai-swap
    ports: ["11434:11434"]
    environment:
      - LLAMA_SERVER=http://tinai-llama:8081
    depends_on: [tinai-llama]
    restart: unless-stopped
SWAP
fi

if echo "$CHOICES" | grep -q "Caddy"; then
    cat >> docker-compose.yml << 'CADDY'
  tinai-caddy:
    image: caddy:alpine
    container_name: tinai-caddy
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
    depends_on: [tinai-webui, tinai-code, tinai-openfang]
    restart: unless-stopped
CADDY
    cat > Caddyfile << 'CADDYFILE'
chat.local { reverse_proxy tinai-webui:8080 }
code.local { reverse_proxy tinai-code:8080 }
agents.local { reverse_proxy tinai-openfang:4200 }
CADDYFILE
fi

if echo "$CHOICES" | grep -q "Filebrowser"; then
    cat >> docker-compose.yml << 'FILE'
  tinai-filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: tinai-filebrowser
    ports: ["8083:80"]
    volumes: ["./projects:/srv", "filebrowser-db:/database"]
    restart: unless-stopped
FILE
fi

# Volumes finaux
cat >> docker-compose.yml << 'VOLUMES'
volumes:
  open-webui-data:
  code-data:
  lancedb-data:
  caddy-data:
  filebrowser-db:
VOLUMES

echo "✅ docker-compose.yml généré avec tes choix !"
echo "🚀 Lancement de TinAI..."
docker compose up -d

echo "
🎉 TinAI est prêt ! Accès rapides :
• Open WebUI          → http://IP:3000
• VS Code             → http://IP:8080     (mdp: changezmoi123)
• Filebrowser         → http://IP:8083
• OpenFang (agents)   → http://IP:4200
• Chat direct         → http://IP:8081
