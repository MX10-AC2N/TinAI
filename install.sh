#!/bin/bash
set -e

echo "🚀 Bienvenue dans TinAI – Tiny AI Dev Assistant"

# ── Mode CI : bypass du menu interactif ──────────────────────────────────────
if [ "${CI:-}" = "true" ]; then
    echo "🤖 Mode CI – sélection automatique de tous les composants"
    CHOICES="llama-server (base obligatoire)
Open WebUI (frontend riche + RAG)
Code-Server + Continue.dev (VS Code web)
Aider (pair programming autonome)
OpenFang (agents autonomes 24/7)
LanceDB RAG (mémoire persistante des projets)
llama-swap (switch modèles à chaud)
Caddy + Filebrowser (URLs propres + explorateur)"
else
    if ! command -v gum &> /dev/null; then
        echo "📦 Installation de gum..."
        curl -fsSL https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz \
            -o /tmp/gum.tar.gz
        tar -xzf /tmp/gum.tar.gz -C /tmp/
        GUM_BIN=$(find /tmp -name "gum" -type f 2>/dev/null | head -1)
        sudo mv "$GUM_BIN" /usr/local/bin/gum
        rm -f /tmp/gum.tar.gz
    fi

    CHOICES=$(gum choose --no-limit \
        "llama-server (base obligatoire)" \
        "Open WebUI (frontend riche + RAG)" \
        "Code-Server + Continue.dev (VS Code web)" \
        "Aider (pair programming autonome)" \
        "OpenFang (agents autonomes 24/7)" \
        "LanceDB RAG (mémoire persistante des projets)" \
        "llama-swap (switch modèles à chaud)" \
        "Caddy + Filebrowser (URLs propres + explorateur)")
fi

# ── Création de la structure ──────────────────────────────────────────────────
mkdir -p TinAI && cd TinAI
mkdir -p models projects

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
EOF

# ── llama-server (toujours présent) ──────────────────────────────────────────
cat >> docker-compose.yml << 'BASE'
  llama-server:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-llama
    ports: ["8081:8081"]
    volumes: ["./models:/models"]
    command: >
      -hf bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --model-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --port 8081 --ctx-size 8192
      --threads 4 --n-gpu-layers 0 --jinja
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 5.5g
BASE

# ── Open WebUI ────────────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Open WebUI"; then
cat >> docker-compose.yml << 'WEBUI'
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: tinai-webui
    ports: ["3000:8080"]
    volumes: ["open-webui-data:/app/backend/data"]
    environment:
      - OPENAI_API_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-123456789
    depends_on: [llama-server]
    restart: unless-stopped
WEBUI
fi

# ── Code-Server ───────────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Code-Server"; then
cat >> docker-compose.yml << 'CODE'
  code-server:
    image: ghcr.io/coder/code-server:latest
    container_name: tinai-code
    ports: ["8080:8080"]
    volumes:
      - ./projects:/home/coder/project
      - code-data:/home/coder/.local/share/code-server
    environment:
      - PASSWORD=changezmoi123
    restart: unless-stopped
CODE
fi

# ── Aider ─────────────────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Aider"; then
cat >> docker-compose.yml << 'AIDER'
  aider:
    image: paulgauthier/aider:latest
    container_name: tinai-aider
    volumes: ["./projects:/app"]
    environment:
      - OPENAI_API_BASE=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-123456789
      - AIDER_MODEL=qwen-coder-3b
    depends_on: [llama-server]
    restart: unless-stopped
AIDER
fi

# ── OpenFang (buildée en CI depuis le source) ─────────────────────────────────
if echo "$CHOICES" | grep -q "OpenFang"; then
cat >> docker-compose.yml << 'FANG'
  openfang:
    image: tinai-openfang:latest
    container_name: tinai-openfang
    ports: ["4200:4200"]
    environment:
      - OPENAI_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-123456789
    depends_on: [llama-server]
    restart: unless-stopped
FANG
fi

# ── LanceDB ───────────────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "LanceDB"; then
cat >> docker-compose.yml << 'LANCEDB'
  lancedb:
    image: lancedb/lancedb:latest
    container_name: tinai-lancedb
    ports: ["8082:8082"]
    volumes: ["lancedb-data:/data"]
    restart: unless-stopped
LANCEDB
fi

# ── llama-swap ────────────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "llama-swap"; then
cat > llama-swap-config.yaml << 'SWAPCONF'
models:
  qwen-coder-3b:
    cmd: >
      llama-server --port ${PORT}
      -hf bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --model-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja
SWAPCONF

cat >> docker-compose.yml << 'SWAP'
  llama-swap:
    image: ghcr.io/mostlygeek/llama-swap:cpu
    container_name: tinai-swap
    ports: ["11434:8080"]
    volumes: ["./llama-swap-config.yaml:/app/config.yaml"]
    restart: unless-stopped
SWAP
fi

# ── Caddy + Filebrowser ───────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Caddy"; then
cat > Caddyfile << 'CADDYFILE'
:80 {
    respond "TinAI Gateway – OK" 200
}
CADDYFILE

cat >> docker-compose.yml << 'CADDY'
  caddy:
    image: caddy:alpine
    container_name: tinai-caddy
    ports: ["80:80"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
    restart: unless-stopped
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: tinai-filebrowser
    ports: ["8083:80"]
    volumes:
      - ./projects:/srv
      - filebrowser-db:/database
    restart: unless-stopped
CADDY
fi

# ── Volumes ───────────────────────────────────────────────────────────────────
cat >> docker-compose.yml << 'VOLUMES'
volumes:
  open-webui-data:
  code-data:
  lancedb-data:
  caddy-data:
  filebrowser-db:
VOLUMES

echo "✅ docker-compose.yml généré !"

# ── Lancement (pas en CI) ─────────────────────────────────────────────────────
if [ "${CI:-}" != "true" ]; then
    docker compose up -d
    echo "
🎉 TinAI est prêt !
• Open WebUI  → http://IP:3000
• VS Code     → http://IP:8080  (mdp: changezmoi123)
• Chat direct → http://IP:8081
• OpenFang    → http://IP:4200
• Filebrowser → http://IP:8083

docker logs tinai-llama
"
fi
