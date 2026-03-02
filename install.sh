#!/bin/bash
set -e

# ══════════════════════════════════════════════════════════════════
#  TinAI v2 – Tiny AI Dev Assistant
#  Installateur interactif – génère un docker-compose.yml sur mesure
# ══════════════════════════════════════════════════════════════════

TINAI_VERSION="2.0.0"

echo "🧠 TinAI v${TINAI_VERSION} – Tiny AI Dev Assistant"
echo "════════════════════════════════════════════════"

# ── Détection architecture ────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  GUM_ARCH="x86_64" ;;
    aarch64) GUM_ARCH="arm64"  ;;
    armv7l)  GUM_ARCH="armv7"  ;;
    *)
        echo "⚠️  Architecture $ARCH non testée – on tente x86_64"
        GUM_ARCH="x86_64"
        ;;
esac
echo "🖥️  Architecture détectée : $ARCH ($GUM_ARCH)"

# ── Détection RAM disponible ──────────────────────────────────────
TOTAL_RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
TOTAL_RAM_GB=$(awk "BEGIN {printf \"%.1f\", $TOTAL_RAM_MB/1024}")
echo "💾 RAM disponible : ${TOTAL_RAM_GB} GB"

if [ "$TOTAL_RAM_MB" -lt 4096 ]; then
    echo "⚠️  Moins de 4 GB RAM – certains services risquent d'être instables"
fi

# ── Mode CI : bypass menu interactif ─────────────────────────────
if [ "${CI:-}" = "true" ]; then
    echo "🤖 Mode CI – sélection automatique de tous les composants"
    CHOICES="llama-server (base obligatoire)
Open WebUI (frontend riche + RAG)
SillyTavern (frontend créatif)
Code-Server + Continue.dev (VS Code web)
Aider (pair programming autonome)
OpenFang (agents autonomes 24/7)
Embedding dédié – nomic-embed-text (RAG propre)
Qdrant RAG (mémoire persistante des projets)
Multimodal – Qwen2.5-VL (vision + texte)
ComfyUI (génération d'images locale)
llama-swap (switch modèles à chaud)
Caddy + Filebrowser (URLs propres + explorateur)"
else
    # ── Installation de gum ───────────────────────────────────────
    if ! command -v gum &> /dev/null; then
        echo "📦 Installation de gum (menu interactif)..."
        GUM_URL="https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_${GUM_ARCH}.tar.gz"
        curl -fsSL "$GUM_URL" -o /tmp/gum.tar.gz
        tar -xzf /tmp/gum.tar.gz -C /tmp/
        GUM_BIN=$(find /tmp -name "gum" -type f 2>/dev/null | head -1)
        if [ -z "$GUM_BIN" ]; then
            echo "❌ Impossible de trouver le binaire gum après extraction"
            exit 1
        fi
        sudo mv "$GUM_BIN" /usr/local/bin/gum
        rm -f /tmp/gum.tar.gz
        echo "✅ gum installé"
    fi

    RAM_WARN=""
    if [ "$TOTAL_RAM_MB" -lt 8192 ]; then
        RAM_WARN=" ⚠️  RAM limitée"
    fi

    echo ""
    echo "👇 Coche les composants (espace = cocher, entrée = valider) :"
    echo "   RAM disponible : ${TOTAL_RAM_GB} GB${RAM_WARN}"
    echo ""

    CHOICES=$(gum choose --no-limit \
        "llama-server (base obligatoire)" \
        "Open WebUI (frontend riche + RAG)" \
        "SillyTavern (frontend créatif)" \
        "Code-Server + Continue.dev (VS Code web)" \
        "Aider (pair programming autonome)" \
        "OpenFang (agents autonomes 24/7)" \
        "Embedding dédié – nomic-embed-text (RAG propre)" \
        "Qdrant RAG (mémoire persistante des projets)" \
        "Multimodal – Qwen2.5-VL (vision + texte)" \
        "ComfyUI (génération d'images locale)" \
        "llama-swap (switch modèles à chaud)" \
        "Caddy + Filebrowser (URLs propres + explorateur)")
fi

# ── Création de la structure ──────────────────────────────────────
mkdir -p TinAI && cd TinAI
mkdir -p models projects comfyui/models comfyui/output

# ════════════════════════════════════════════════════════════════
#  Génération du docker-compose.yml
# ════════════════════════════════════════════════════════════════

cat > docker-compose.yml << 'EOF'
services:
EOF

# ── llama-server ─────────────────────────────────────────────────
cat >> docker-compose.yml << 'BASE'
  llama-server:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-llama
    ports: ["8081:8081"]
    volumes: ["./models:/models"]
    command: >
      --hf-repo bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --hf-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --port 8081 --ctx-size 8192
      --threads 4 --n-gpu-layers 0 --jinja
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s
    deploy:
      resources:
        limits:
          memory: 5.5g
BASE

# ── Open WebUI ────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Open WebUI"; then
cat >> docker-compose.yml << 'WEBUI'
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: tinai-webui
    ports: ["3000:8080"]
    volumes: ["open-webui-data:/app/backend/data"]
    environment:
      - OPENAI_API_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-tinai
    depends_on:
      llama-server:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
WEBUI
fi

# ── SillyTavern ───────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "SillyTavern"; then
cat >> docker-compose.yml << 'SILLY'
  sillytavern:
    image: ghcr.io/sillytavern/sillytavern:latest
    container_name: tinai-sillytavern
    ports: ["8008:8000"]
    volumes:
      - sillytavern-data:/home/node/app/data
      - sillytavern-config:/home/node/app/config
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
SILLY
fi

# ── Code-Server ───────────────────────────────────────────────────
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
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
CODE
fi

# ── Aider ─────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Aider"; then
cat >> docker-compose.yml << 'AIDER'
  aider:
    image: paulgauthier/aider:latest
    container_name: tinai-aider
    volumes: ["./projects:/app"]
    environment:
      - OPENAI_API_BASE=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-tinai
      - AIDER_MODEL=qwen-coder-3b
    depends_on:
      llama-server:
        condition: service_healthy
    restart: unless-stopped
AIDER
fi

# ── OpenFang ──────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "OpenFang"; then
cat >> docker-compose.yml << 'FANG'
  openfang:
    image: tinai-openfang:latest
    container_name: tinai-openfang
    ports: ["4200:4200"]
    environment:
      - OPENAI_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=sk-tinai
    depends_on:
      llama-server:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4200/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
FANG
fi

# ── Embedding dédié – nomic-embed-text ───────────────────────────
if echo "$CHOICES" | grep -q "Embedding"; then
cat >> docker-compose.yml << 'EMBED'
  embeddings:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-embeddings
    ports: ["8084:8084"]
    volumes: ["./models:/models"]
    command: >
      --hf-repo nomic-ai/nomic-embed-text-v1.5-GGUF
      --hf-file nomic-embed-text-v1.5.Q4_K_M.gguf
      --host 0.0.0.0 --port 8084
      --ctx-size 2048 --threads 2 --n-gpu-layers 0
      --embedding --alias nomic-embed-text
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8084/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      resources:
        limits:
          memory: 1g
EMBED
fi

# ── Qdrant ────────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "Qdrant"; then
cat >> docker-compose.yml << 'QDRANT'
  qdrant:
    image: qdrant/qdrant:latest
    container_name: tinai-qdrant
    ports: ["6333:6333", "6334:6334"]
    volumes: ["qdrant-data:/qdrant/storage"]
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
QDRANT
fi

# ── Multimodal – LLaVA-Phi-3-mini (vision + texte, 1 seul fichier) ────────────
if echo "$CHOICES" | grep -q "Multimodal"; then
cat >> docker-compose.yml << 'VISION'
  vision:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-vision
    ports: ["8085:8085"]
    volumes: ["./models:/models"]
    command: >
      --hf-repo xtuner/llava-phi-3-mini-gguf
      --hf-file llava-phi-3-mini-f16.gguf
      --host 0.0.0.0 --port 8085
      --ctx-size 4096 --threads 4 --n-gpu-layers 0
      --alias llava-phi3-mini
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8085/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s
    deploy:
      resources:
        limits:
          memory: 4g
VISION
fi

# ── ComfyUI ───────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "ComfyUI"; then
cat >> docker-compose.yml << 'COMFY'
  comfyui:
    image: ghcr.io/ai-dock/comfyui:latest-cpu
    container_name: tinai-comfyui
    ports: ["7860:7860"]
    volumes:
      - ./comfyui/models:/opt/ComfyUI/models
      - ./comfyui/output:/opt/ComfyUI/output
    environment:
      - CLI_ARGS=--cpu
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7860/"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    deploy:
      resources:
        limits:
          memory: 4g
COMFY
fi

# ── llama-swap ────────────────────────────────────────────────────
if echo "$CHOICES" | grep -q "llama-swap"; then
cat > llama-swap-config.yaml << 'SWAPCONF'
models:
  qwen-coder-3b:
    cmd: >
      llama-server --port ${PORT}
      --hf-repo bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --hf-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja
  qwen-vl-3b:
    cmd: >
      llama-server --port ${PORT}
      --hf-repo bartowski/Qwen2.5-VL-3B-Instruct-GGUF
      --hf-file Qwen2.5-VL-3B-Instruct-Q4_K_M.gguf
      --host 0.0.0.0 --ctx-size 4096 --threads 4 --n-gpu-layers 0 --jinja
SWAPCONF

cat >> docker-compose.yml << 'SWAP'
  llama-swap:
    image: ghcr.io/mostlygeek/llama-swap:cpu
    container_name: tinai-swap
    ports: ["11434:8080"]
    volumes: ["./llama-swap-config.yaml:/app/config.yaml"]
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
SWAP
fi

# ── Caddy + Filebrowser ───────────────────────────────────────────
if echo "$CHOICES" | grep -q "Caddy"; then
cat > Caddyfile << 'CADDYFILE'
:80 {
    handle /webui* {
        reverse_proxy tinai-webui:8080
    }
    handle /code* {
        reverse_proxy tinai-code:8080
    }
    handle /agents* {
        reverse_proxy tinai-openfang:4200
    }
    handle /files* {
        reverse_proxy tinai-filebrowser:80
    }
    handle /comfy* {
        reverse_proxy tinai-comfyui:7860
    }
    handle /silly* {
        reverse_proxy tinai-sillytavern:8000
    }
    handle {
        respond "TinAI v2 Gateway – OK" 200
    }
}
CADDYFILE

cat >> docker-compose.yml << 'CADDY'
  caddy:
    image: caddy:alpine
    container_name: tinai-caddy
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:80/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
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

# ── Volumes ───────────────────────────────────────────────────────
cat >> docker-compose.yml << 'VOLUMES'
volumes:
  open-webui-data:
  sillytavern-data:
  sillytavern-config:
  code-data:
  qdrant-data:
  caddy-data:
  filebrowser-db:
VOLUMES

echo ""
echo "✅ docker-compose.yml généré avec succès !"

# ── Copie du CLI tinai ────────────────────────────────────────────
if [ -f "../tinai" ]; then
    sudo cp ../tinai /usr/local/bin/tinai
    sudo chmod +x /usr/local/bin/tinai
    # Injecter le bon chemin dans le CLI
    sudo sed -i "s|TINAI_DIR_PLACEHOLDER|$(pwd)|g" /usr/local/bin/tinai
    echo "✅ CLI tinai installé → tinai help"
fi

# ── Lancement (pas en CI) ─────────────────────────────────────────
if [ "${CI:-}" != "true" ]; then
    echo "🚀 Lancement de TinAI..."
    docker compose up -d

    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║         🎉 TinAI v2 est prêt !               ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║  Open WebUI    → http://IP:3000              ║"
    echo "║  SillyTavern   → http://IP:8008              ║"
    echo "║  VS Code       → http://IP:8080              ║"
    echo "║  OpenFang      → http://IP:4200              ║"
    echo "║  ComfyUI       → http://IP:7860              ║"
    echo "║  Filebrowser   → http://IP:8083              ║"
    echo "║  llama-server  → http://IP:8081              ║"
    echo "║  Embeddings    → http://IP:8084              ║"
    echo "║  Vision VL     → http://IP:8085              ║"
    echo "║  Qdrant        → http://IP:6333              ║"
    echo "║  llama-swap    → http://IP:11434             ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║  CLI : tinai status / logs / update / model  ║"
    echo "╚══════════════════════════════════════════════╝"
fi

