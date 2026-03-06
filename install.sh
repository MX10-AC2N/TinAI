#!/bin/bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════════
#  TinAI v2 – Installateur x86_64
#  Usage : bash install.sh
#  Génère docker-compose.yml + CLI tinai sur mesure
# ══════════════════════════════════════════════════════════════════

TINAI_VERSION="2.1.0"
ARCH="x86_64"

# ── Chargement .env ───────────────────────────────────────────────
for envfile in ".env" "../.env"; do
    if [ -f "$envfile" ]; then
        set -a; source "$envfile"; set +a
        echo "📄 Configuration chargée depuis $envfile"
        break
    fi
done

# ── Valeurs par défaut ────────────────────────────────────────────
MODELS_DIR="${MODELS_DIR:-./models}"
PROJECTS_DIR="${PROJECTS_DIR:-./projects}"
COMFYUI_MODELS_DIR="${COMFYUI_MODELS_DIR:-./comfyui/models}"
COMFYUI_OUTPUT_DIR="${COMFYUI_OUTPUT_DIR:-./comfyui/output}"
OPENFANG_CONFIG_DIR="${OPENFANG_CONFIG_DIR:-./openfang-config}"

PORT_LLAMA="${PORT_LLAMA:-8081}"
PORT_WEBUI="${PORT_WEBUI:-3000}"
PORT_SILLYTAVERN="${PORT_SILLYTAVERN:-8008}"
PORT_CODE="${PORT_CODE:-8080}"
PORT_OPENFANG="${PORT_OPENFANG:-4200}"
PORT_EMBEDDINGS="${PORT_EMBEDDINGS:-8084}"
PORT_QDRANT="${PORT_QDRANT:-6333}"
PORT_QDRANT_GRPC="${PORT_QDRANT_GRPC:-6334}"
PORT_VISION="${PORT_VISION:-8085}"
PORT_COMFYUI="${PORT_COMFYUI:-7860}"
PORT_SWAP="${PORT_SWAP:-11434}"
PORT_CADDY="${PORT_CADDY:-80}"
PORT_CADDY_HTTPS="${PORT_CADDY_HTTPS:-443}"
PORT_FILEBROWSER="${PORT_FILEBROWSER:-8083}"

CODE_PASSWORD="${CODE_PASSWORD:-changezmoi123}"
TINAI_API_KEY="${TINAI_API_KEY:-sk-tinai}"

LLAMA_HF_REPO="${LLAMA_HF_REPO:-bartowski/Qwen_Qwen3-2B-GGUF}"
LLAMA_HF_FILE="${LLAMA_HF_FILE:-Qwen_Qwen3-2B-Q5_K_M.gguf}"
AIDER_MODEL="${AIDER_MODEL:-qwen3-2b}"

LLAMA_CTX_SIZE="${LLAMA_CTX_SIZE:-8192}"
LLAMA_THREADS="${LLAMA_THREADS:-4}"
LLAMA_GPU_LAYERS="${LLAMA_GPU_LAYERS:-0}"
LLAMA_MEM_LIMIT="${LLAMA_MEM_LIMIT:-3.5g}"

EMBED_CTX_SIZE="${EMBED_CTX_SIZE:-2048}"
EMBED_THREADS="${EMBED_THREADS:-2}"
EMBED_MEM_LIMIT="${EMBED_MEM_LIMIT:-1g}"

VISION_CTX_SIZE="${VISION_CTX_SIZE:-4096}"
VISION_THREADS="${VISION_THREADS:-4}"
VISION_MEM_LIMIT="${VISION_MEM_LIMIT:-4g}"

COMFYUI_MEM_LIMIT="${COMFYUI_MEM_LIMIT:-4g}"

# ── Images x86_64 (officielles, pas de build local) ───────────────
LLAMA_IMAGE="ghcr.io/ggml-org/llama.cpp:server"
SWAP_IMAGE="ghcr.io/mostlygeek/llama-swap:cpu"
COMFYUI_IMAGE="yanwk/comfyui-boot:cpu"

echo "🧠 TinAI v${TINAI_VERSION} – x86_64"
echo "════════════════════════════════════════════════"

# ── RAM disponible ────────────────────────────────────────────────
TOTAL_RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
TOTAL_RAM_GB=$(awk "BEGIN {printf \"%.1f\", $TOTAL_RAM_MB/1024}")
echo "💾 RAM disponible : ${TOTAL_RAM_GB} GB"
[ "$TOTAL_RAM_MB" -lt 4096 ] && echo "⚠️  Moins de 4 GB RAM – certains services risquent d'être instables"

# ── Vérification Docker ───────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo "❌ Docker non trouvé – installe Docker avant de continuer"
    echo "   https://docs.docker.com/engine/install/"
    exit 1
fi
if ! docker info &>/dev/null; then
    echo "❌ Docker daemon inaccessible – ajoute ton user au groupe docker ou utilise sudo"
    exit 1
fi

# ── Sélection des composants ──────────────────────────────────────
if [ "${CI:-}" = "true" ]; then
    echo "🤖 Mode CI – sélection automatique de tous les composants"
    CHOICES="llama-server
Open WebUI
SillyTavern
Code-Server
Aider
OpenFang
Embedding
Qdrant
Multimodal
ComfyUI
llama-swap
Caddy"
else
    if ! command -v gum &>/dev/null; then
        echo "📦 Installation de gum..."
        GUM_URL="https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz"
        curl -fsSL "$GUM_URL" | tar -xz -C /tmp/
        sudo mv "$(find /tmp -name 'gum' -type f | head -1)" /usr/local/bin/gum
        echo "✅ gum installé"
    fi
    RAM_WARN=""; [ "$TOTAL_RAM_MB" -lt 8192 ] && RAM_WARN=" ⚠️  RAM limitée"
    echo ""
    echo "👇 Sélectionne les composants (espace = cocher, entrée = valider)"
    echo "   RAM : ${TOTAL_RAM_GB} GB${RAM_WARN}"
    echo ""
    CHOICES=$(gum choose --no-limit \
        "llama-server" \
        "Open WebUI" \
        "SillyTavern" \
        "Code-Server" \
        "Aider" \
        "OpenFang" \
        "Embedding" \
        "Qdrant" \
        "Multimodal" \
        "ComfyUI" \
        "llama-swap" \
        "Caddy")
fi

# ── Création de la structure ──────────────────────────────────────
mkdir -p TinAI && cd TinAI
mkdir -p "${MODELS_DIR}" "${PROJECTS_DIR}" "${COMFYUI_MODELS_DIR}" "${COMFYUI_OUTPUT_DIR}"
INSTALL_DIR="$(pwd)"

# ════════════════════════════════════════════════════════════════
#  Génération docker-compose.yml
# ════════════════════════════════════════════════════════════════
cat > docker-compose.yml << 'EOF'
services:
EOF

# llama-server (toujours présent)
cat >> docker-compose.yml << BASE
  llama-server:
    image: ${LLAMA_IMAGE}
    container_name: tinai-llama
    ports: ["${PORT_LLAMA}:8081"]
    volumes: ["${MODELS_DIR}:/models"]
    command: >
      --hf-repo ${LLAMA_HF_REPO}
      --hf-file ${LLAMA_HF_FILE}
      --host 0.0.0.0 --port 8081
      --ctx-size ${LLAMA_CTX_SIZE}
      --threads ${LLAMA_THREADS}
      --n-gpu-layers ${LLAMA_GPU_LAYERS}
      --jinja
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/health"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 300s
    deploy:
      resources:
        limits:
          memory: ${LLAMA_MEM_LIMIT}
BASE

echo "$CHOICES" | grep -q "Open WebUI" && cat >> docker-compose.yml << WEBUI
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: tinai-webui
    ports: ["${PORT_WEBUI}:8080"]
    volumes: ["open-webui-data:/app/backend/data"]
    environment:
      - OPENAI_API_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=${TINAI_API_KEY}
    depends_on:
      llama-server:
        condition: service_started
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
WEBUI

echo "$CHOICES" | grep -q "SillyTavern" && cat >> docker-compose.yml << SILLY
  sillytavern:
    image: ghcr.io/sillytavern/sillytavern:release
    container_name: tinai-sillytavern
    ports: ["${PORT_SILLYTAVERN}:8000"]
    volumes:
      - sillytavern-data:/home/node/app/data
      - sillytavern-config:/home/node/app/config
    environment:
      - SILLYTAVERN_HEARTBEATINTERVAL=30
      - NODE_ENV=production
      - SILLYTAVERN_WHITELISTMODE=false
      - SILLYTAVERN_BASICAUTHMODE=false
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:8000/"]
      interval: 15s
      timeout: 10s
      retries: 20
      start_period: 120s
SILLY

echo "$CHOICES" | grep -q "Code-Server" && cat >> docker-compose.yml << CODE
  code-server:
    image: ghcr.io/coder/code-server:latest
    container_name: tinai-code
    ports: ["${PORT_CODE}:8080"]
    volumes:
      - ${PROJECTS_DIR}:/home/coder/project
      - code-data:/home/coder/.local/share/code-server
    environment:
      - PASSWORD=${CODE_PASSWORD}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
CODE

echo "$CHOICES" | grep -q "Aider" && cat >> docker-compose.yml << AIDER
  aider:
    image: paulgauthier/aider:latest
    container_name: tinai-aider
    entrypoint: ["/bin/sh", "-c", "tail -f /dev/null"]
    volumes: ["${PROJECTS_DIR}:/app"]
    environment:
      - OPENAI_API_BASE=http://llama-server:8081/v1
      - OPENAI_API_KEY=${TINAI_API_KEY}
      - AIDER_MODEL=${AIDER_MODEL}
    depends_on:
      llama-server:
        condition: service_started
    restart: on-failure
AIDER

if echo "$CHOICES" | grep -q "OpenFang"; then
    mkdir -p "${OPENFANG_CONFIG_DIR}"
    cat > "${OPENFANG_CONFIG_DIR}/openfang.toml" << OPENFANGCONF
[server]
host = "0.0.0.0"
port = 4200

[llm]
base_url = "http://llama-server:8081/v1"
api_key = "${TINAI_API_KEY}"
model = "${AIDER_MODEL}"

[agents]
dir = "/opt/openfang/agents"
OPENFANGCONF
    cat >> docker-compose.yml << FANG
  openfang:
    image: tinai-openfang:latest
    container_name: tinai-openfang
    ports: ["${PORT_OPENFANG}:4200"]
    volumes: ["${OPENFANG_CONFIG_DIR}:/etc/openfang"]
    environment:
      - OPENAI_BASE_URL=http://llama-server:8081/v1
      - OPENAI_API_KEY=${TINAI_API_KEY}
      - OPENFANG_CONFIG=/etc/openfang/openfang.toml
    depends_on:
      llama-server:
        condition: service_started
    restart: on-failure
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4200/"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
FANG
fi

echo "$CHOICES" | grep -q "Embedding" && cat >> docker-compose.yml << EMBED
  embeddings:
    image: ${LLAMA_IMAGE}
    container_name: tinai-embeddings
    ports: ["${PORT_EMBEDDINGS}:8084"]
    volumes: ["${MODELS_DIR}:/models"]
    command: >
      --hf-repo nomic-ai/nomic-embed-text-v1.5-GGUF
      --hf-file nomic-embed-text-v1.5.Q4_K_M.gguf
      --host 0.0.0.0 --port 8084
      --ctx-size ${EMBED_CTX_SIZE}
      --threads ${EMBED_THREADS}
      --n-gpu-layers ${LLAMA_GPU_LAYERS}
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
          memory: ${EMBED_MEM_LIMIT}
EMBED

echo "$CHOICES" | grep -q "Qdrant" && cat >> docker-compose.yml << QDRANT
  qdrant:
    image: qdrant/qdrant:latest
    container_name: tinai-qdrant
    ports: ["${PORT_QDRANT}:6333", "${PORT_QDRANT_GRPC}:6334"]
    volumes: ["qdrant-data:/qdrant/storage"]
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
QDRANT

echo "$CHOICES" | grep -q "Multimodal" && cat >> docker-compose.yml << VISION
  vision:
    image: ${LLAMA_IMAGE}
    container_name: tinai-vision
    ports: ["${PORT_VISION}:8085"]
    volumes: ["${MODELS_DIR}:/models"]
    command: >
      --hf-repo xtuner/llava-phi-3-mini-gguf
      --hf-file llava-phi-3-mini-f16.gguf
      --host 0.0.0.0 --port 8085
      --ctx-size ${VISION_CTX_SIZE}
      --threads ${VISION_THREADS}
      --n-gpu-layers ${LLAMA_GPU_LAYERS}
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
          memory: ${VISION_MEM_LIMIT}
VISION

echo "$CHOICES" | grep -q "ComfyUI" && cat >> docker-compose.yml << COMFY
  comfyui:
    image: ${COMFYUI_IMAGE}
    container_name: tinai-comfyui
    ports: ["${PORT_COMFYUI}:8188"]
    volumes:
      - ${COMFYUI_MODELS_DIR}:/root/ComfyUI/models
      - ${COMFYUI_OUTPUT_DIR}:/root/ComfyUI/output
    environment:
      - CLI_ARGS=--cpu --listen 0.0.0.0
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:8188/system_stats"]
      interval: 30s
      timeout: 15s
      retries: 10
      start_period: 300s
    deploy:
      resources:
        limits:
          memory: ${COMFYUI_MEM_LIMIT}
COMFY

if echo "$CHOICES" | grep -q "llama-swap"; then
    cat > llama-swap-config.yaml << SWAPCONF
models:
  qwen3-2b:
    cmd: >
      llama-server --port \${PORT}
      --hf-repo bartowski/Qwen_Qwen3-2B-GGUF
      --hf-file Qwen_Qwen3-2B-Q5_K_M.gguf
      --host 0.0.0.0 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja
  qwen3-8b:
    cmd: >
      llama-server --port \${PORT}
      --hf-repo bartowski/Qwen_Qwen3-8B-GGUF
      --hf-file Qwen_Qwen3-8B-Q4_K_M.gguf
      --host 0.0.0.0 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja
  qwen3-vl-3b:
    cmd: >
      llama-server --port \${PORT}
      --hf-repo bartowski/Qwen_Qwen3-VL-3B-Instruct-GGUF
      --hf-file Qwen_Qwen3-VL-3B-Instruct-Q4_K_M.gguf
      --host 0.0.0.0 --ctx-size 4096 --threads 4 --n-gpu-layers 0 --jinja
SWAPCONF
    cat >> docker-compose.yml << SWAP
  llama-swap:
    image: ${SWAP_IMAGE}
    container_name: tinai-swap
    ports: ["${PORT_SWAP}:8080"]
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

if echo "$CHOICES" | grep -q "Caddy"; then
    cat > Caddyfile << CADDYFILE
:80 {
    handle /webui*      { reverse_proxy tinai-webui:8080 }
    handle /code*       { reverse_proxy tinai-code:8080 }
    handle /agents*     { reverse_proxy tinai-openfang:4200 }
    handle /files*      { reverse_proxy tinai-filebrowser:80 }
    handle /comfy*      { reverse_proxy tinai-comfyui:8188 }
    handle /silly*      { reverse_proxy tinai-sillytavern:8000 }
    handle              { respond "TinAI v2 Gateway – OK" 200 }
}
CADDYFILE
    cat >> docker-compose.yml << CADDY
  caddy:
    image: caddy:alpine
    container_name: tinai-caddy
    ports: ["${PORT_CADDY}:80", "${PORT_CADDY_HTTPS}:443"]
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
    ports: ["${PORT_FILEBROWSER}:80"]
    volumes:
      - ${PROJECTS_DIR}:/srv
      - filebrowser-db:/database
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
CADDY
fi

cat >> docker-compose.yml << VOLUMES
volumes:
  open-webui-data:
  sillytavern-data:
  sillytavern-config:
  code-data:
  qdrant-data:
  caddy-data:
  filebrowser-db:
VOLUMES

echo "✅ docker-compose.yml généré"

# ════════════════════════════════════════════════════════════════
#  Génération du CLI tinai (adapté aux choix + architecture)
# ════════════════════════════════════════════════════════════════

# Construire la liste des services installés pour cmd_status
INSTALLED_SERVICES=""
docker_image_for_llama="$LLAMA_IMAGE"

echo "$CHOICES" | grep -q "Open WebUI"   && INSTALLED_SERVICES+=" tinai-webui:${PORT_WEBUI}"
echo "$CHOICES" | grep -q "SillyTavern"  && INSTALLED_SERVICES+=" tinai-sillytavern:${PORT_SILLYTAVERN}"
echo "$CHOICES" | grep -q "Code-Server"  && INSTALLED_SERVICES+=" tinai-code:${PORT_CODE}"
echo "$CHOICES" | grep -q "Aider"        && INSTALLED_SERVICES+=" tinai-aider:"
echo "$CHOICES" | grep -q "OpenFang"     && INSTALLED_SERVICES+=" tinai-openfang:${PORT_OPENFANG}"
echo "$CHOICES" | grep -q "Embedding"    && INSTALLED_SERVICES+=" tinai-embeddings:${PORT_EMBEDDINGS}"
echo "$CHOICES" | grep -q "Qdrant"       && INSTALLED_SERVICES+=" tinai-qdrant:${PORT_QDRANT}"
echo "$CHOICES" | grep -q "Multimodal"   && INSTALLED_SERVICES+=" tinai-vision:${PORT_VISION}"
echo "$CHOICES" | grep -q "ComfyUI"      && INSTALLED_SERVICES+=" tinai-comfyui:${PORT_COMFYUI}"
echo "$CHOICES" | grep -q "llama-swap"   && INSTALLED_SERVICES+=" tinai-swap:${PORT_SWAP}"
echo "$CHOICES" | grep -q "Caddy"        && INSTALLED_SERVICES+=" tinai-caddy:${PORT_CADDY} tinai-filebrowser:${PORT_FILEBROWSER}"

cat > /tmp/tinai-generated << CLISCRIPT
#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  tinai – CLI TinAI v${TINAI_VERSION}
#  Généré le $(date -u +"%Y-%m-%d %H:%M UTC") par install.sh (${ARCH})
#  Services installés : llama-server${INSTALLED_SERVICES}
# ══════════════════════════════════════════════════════════════════

TINAI_VERSION="${TINAI_VERSION}"
TINAI_DIR="${INSTALL_DIR}"
COMPOSE_FILE="${INSTALL_DIR}/docker-compose.yml"
ARCH="${ARCH}"
LLAMA_IMAGE="${docker_image_for_llama}"
MODELS_DIR="${MODELS_DIR}"
LLAMA_MEM_LIMIT="${LLAMA_MEM_LIMIT}"
LLAMA_CTX_SIZE="${LLAMA_CTX_SIZE}"
LLAMA_THREADS="${LLAMA_THREADS}"
LLAMA_GPU_LAYERS="${LLAMA_GPU_LAYERS}"
LLAMA_HF_REPO="${LLAMA_HF_REPO}"
LLAMA_HF_FILE="${LLAMA_HF_FILE}"
PORT_LLAMA="${PORT_LLAMA}"
PORT_WEBUI="${PORT_WEBUI}"
PORT_SILLYTAVERN="${PORT_SILLYTAVERN}"
PORT_CODE="${PORT_CODE}"
PORT_OPENFANG="${PORT_OPENFANG}"
PORT_EMBEDDINGS="${PORT_EMBEDDINGS}"
PORT_QDRANT="${PORT_QDRANT}"
PORT_VISION="${PORT_VISION}"
PORT_COMFYUI="${PORT_COMFYUI}"
PORT_SWAP="${PORT_SWAP}"
PORT_CADDY="${PORT_CADDY}"
PORT_FILEBROWSER="${PORT_FILEBROWSER}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

check_compose() {
    [ -f "\$COMPOSE_FILE" ] || { echo -e "\${RED}❌ docker-compose.yml introuvable dans \$TINAI_DIR\${RESET}"; exit 1; }
}

cmd_status() {
    check_compose
    echo -e "\${BOLD}🧠 TinAI v\${TINAI_VERSION} (\${ARCH}) – État des services\${RESET}"
    echo "═══════════════════════════════════════════════════"
    declare -A SVC_PORTS=(
        [tinai-llama]="\${PORT_LLAMA}"
$(echo "$CHOICES" | grep -q "Open WebUI"   && echo "        [tinai-webui]=\"\${PORT_WEBUI}\"")
$(echo "$CHOICES" | grep -q "SillyTavern"  && echo "        [tinai-sillytavern]=\"\${PORT_SILLYTAVERN}\"")
$(echo "$CHOICES" | grep -q "Code-Server"  && echo "        [tinai-code]=\"\${PORT_CODE}\"")
$(echo "$CHOICES" | grep -q "Aider"        && echo "        [tinai-aider]=\"\"")
$(echo "$CHOICES" | grep -q "OpenFang"     && echo "        [tinai-openfang]=\"\${PORT_OPENFANG}\"")
$(echo "$CHOICES" | grep -q "Embedding"    && echo "        [tinai-embeddings]=\"\${PORT_EMBEDDINGS}\"")
$(echo "$CHOICES" | grep -q "Qdrant"       && echo "        [tinai-qdrant]=\"\${PORT_QDRANT}\"")
$(echo "$CHOICES" | grep -q "Multimodal"   && echo "        [tinai-vision]=\"\${PORT_VISION}\"")
$(echo "$CHOICES" | grep -q "ComfyUI"      && echo "        [tinai-comfyui]=\"\${PORT_COMFYUI}\"")
$(echo "$CHOICES" | grep -q "llama-swap"   && echo "        [tinai-swap]=\"\${PORT_SWAP}\"")
$(echo "$CHOICES" | grep -q "Caddy"        && echo "        [tinai-caddy]=\"\${PORT_CADDY}\"")
$(echo "$CHOICES" | grep -q "Caddy"        && echo "        [tinai-filebrowser]=\"\${PORT_FILEBROWSER}\"")
    )
    declare -A SVC_LABELS=(
        [tinai-llama]="llama-server  "
$(echo "$CHOICES" | grep -q "Open WebUI"   && echo "        [tinai-webui]=\"Open WebUI    \"")
$(echo "$CHOICES" | grep -q "SillyTavern"  && echo "        [tinai-sillytavern]=\"SillyTavern   \"")
$(echo "$CHOICES" | grep -q "Code-Server"  && echo "        [tinai-code]=\"Code-Server   \"")
$(echo "$CHOICES" | grep -q "Aider"        && echo "        [tinai-aider]=\"Aider         \"")
$(echo "$CHOICES" | grep -q "OpenFang"     && echo "        [tinai-openfang]=\"OpenFang      \"")
$(echo "$CHOICES" | grep -q "Embedding"    && echo "        [tinai-embeddings]=\"Embeddings    \"")
$(echo "$CHOICES" | grep -q "Qdrant"       && echo "        [tinai-qdrant]=\"Qdrant        \"")
$(echo "$CHOICES" | grep -q "Multimodal"   && echo "        [tinai-vision]=\"Vision VL     \"")
$(echo "$CHOICES" | grep -q "ComfyUI"      && echo "        [tinai-comfyui]=\"ComfyUI       \"")
$(echo "$CHOICES" | grep -q "llama-swap"   && echo "        [tinai-swap]=\"llama-swap    \"")
$(echo "$CHOICES" | grep -q "Caddy"        && echo "        [tinai-caddy]=\"Caddy         \"")
$(echo "$CHOICES" | grep -q "Caddy"        && echo "        [tinai-filebrowser]=\"Filebrowser   \"")
    )
    for container in "\${!SVC_LABELS[@]}"; do
        STATE=\$(docker inspect --format='{{.State.Status}}' "\$container" 2>/dev/null || echo "absent")
        [ "\$STATE" = "absent" ] && continue
        PORT="\${SVC_PORTS[\$container]}"
        LABEL="\${SVC_LABELS[\$container]}"
        if [ "\$STATE" = "running" ]; then
            if [ -n "\$PORT" ] && curl -sSf --max-time 2 "http://127.0.0.1:\$PORT/" >/dev/null 2>&1; then
                echo -e "  \${GREEN}✅\${RESET} \${LABEL} → \${CYAN}http://localhost:\${PORT}\${RESET}"
            elif [ -n "\$PORT" ]; then
                echo -e "  \${YELLOW}⏳\${RESET} \${LABEL} → démarrage (port \$PORT)"
            else
                echo -e "  \${GREEN}✅\${RESET} \${LABEL} → actif"
            fi
        else
            echo -e "  \${RED}❌\${RESET} \${LABEL} → \$STATE"
        fi
    done
    echo ""
    echo -e "\${BOLD}💾 Ressources :\${RESET}"
    docker stats --no-stream --format "  {{.Name}}\tCPU: {{.CPUPerc}}\tMEM: {{.MemUsage}}" 2>/dev/null | grep "tinai-" | column -t
}

cmd_logs() {
    check_compose
    cd "\$TINAI_DIR"
    SERVICES=\$(docker compose ps --services 2>/dev/null)
    if [ -z "\${1:-}" ]; then
        if command -v gum &>/dev/null; then
            SVC=\$(echo "\$SERVICES" | gum choose --header "Quel service ?")
        else
            echo "\$SERVICES" | nl -ba
            read -rp "Numéro : " NUM
            SVC=\$(echo "\$SERVICES" | sed -n "\${NUM}p")
        fi
    else
        SVC="\$1"
    fi
    [ -z "\$SVC" ] && exit 0
    echo -e "\${CYAN}📋 Logs de \$SVC (Ctrl+C pour quitter)\${RESET}"
    docker compose logs -f --tail=100 "\$SVC"
}

cmd_update() {
    check_compose
    cd "\$TINAI_DIR"
    echo -e "\${BOLD}🔄 Mise à jour des images...\${RESET}"
    docker compose pull
    docker compose up -d --remove-orphans
    echo -e "\${GREEN}✅ TinAI mis à jour\${RESET}"
}

cmd_model() {
    check_compose
    cd "\$TINAI_DIR"
    echo -e "\${BOLD}🤖 Changement de modèle llama-server (${ARCH})\${RESET}"
    echo "   Modèle actuel : \${CYAN}\${LLAMA_HF_FILE}\${RESET}"
    echo ""
    declare -A MODELS=(
        ["Qwen3-2B      – 1.7 GB (défaut)"]="--hf-repo bartowski/Qwen_Qwen3-2B-GGUF --hf-file Qwen_Qwen3-2B-Q5_K_M.gguf"
        ["Qwen3-8B      – 5.2 GB"]="--hf-repo bartowski/Qwen_Qwen3-8B-GGUF --hf-file Qwen_Qwen3-8B-Q4_K_M.gguf"
        ["Qwen3-14B     – 9.0 GB"]="--hf-repo bartowski/Qwen_Qwen3-14B-GGUF --hf-file Qwen_Qwen3-14B-Q4_K_M.gguf"
        ["Qwen3-VL-3B   – 2.3 GB (vision)"]="--hf-repo bartowski/Qwen_Qwen3-VL-3B-Instruct-GGUF --hf-file Qwen_Qwen3-VL-3B-Instruct-Q4_K_M.gguf"
        ["Mistral-7B    – 4.1 GB"]="--hf-repo bartowski/Mistral-7B-Instruct-v0.3-GGUF --hf-file Mistral-7B-Instruct-v0.3-Q4_K_M.gguf"
        ["Phi-3.5-mini  – 2.2 GB"]="--hf-repo bartowski/Phi-3.5-mini-instruct-GGUF --hf-file Phi-3.5-mini-instruct-Q4_K_M.gguf"
    )
    MODEL_NAMES=("\${!MODELS[@]}")
    if command -v gum &>/dev/null; then
        SELECTED=\$(printf '%s\n' "\${MODEL_NAMES[@]}" | gum choose --header "Choisis un modèle :")
    else
        for i in "\${!MODEL_NAMES[@]}"; do echo "  \$((i+1))) \${MODEL_NAMES[\$i]}"; done
        read -rp "Numéro : " NUM
        SELECTED="\${MODEL_NAMES[\$((NUM-1))]}"
    fi
    [ -z "\$SELECTED" ] && exit 0
    ARGS="\${MODELS[\$SELECTED]}"
    FULL_CMD="\$ARGS --host 0.0.0.0 --port 8081 --ctx-size \${LLAMA_CTX_SIZE} --threads \${LLAMA_THREADS} --n-gpu-layers \${LLAMA_GPU_LAYERS} --jinja"
    echo -e "\${YELLOW}🔄 Remplacement de llama-server...\${RESET}"
    docker rm -f tinai-llama 2>/dev/null || true
    NETWORK=\$(docker network ls --filter "name=\$(basename \$TINAI_DIR)" --format "{{.Name}}" | head -1)
    docker run -d \
        --name tinai-llama \
        --network "\$NETWORK" \
        -p "\${PORT_LLAMA}:8081" \
        -v "\${TINAI_DIR}/\${MODELS_DIR}:/models" \
        --memory "\${LLAMA_MEM_LIMIT}" \
        "\${LLAMA_IMAGE}" \
        \$FULL_CMD
    echo -e "\${GREEN}✅ Modèle changé : \$SELECTED\${RESET}"
}

cmd_stop()    { check_compose; cd "\$TINAI_DIR"; echo -e "\${YELLOW}⏹️  Arrêt...\${RESET}"; docker compose down; echo -e "\${GREEN}✅ TinAI arrêté\${RESET}"; }
cmd_start()   { check_compose; cd "\$TINAI_DIR"; echo -e "\${GREEN}▶️  Démarrage...\${RESET}"; docker compose up -d; sleep 3; cmd_status; }
cmd_restart() { cmd_stop; sleep 2; cmd_start; }

cmd_help() {
    echo -e "\${BOLD}🧠 TinAI v\${TINAI_VERSION} (\${ARCH}) – CLI\${RESET}"
    echo ""
    echo "Usage : tinai <commande> [options]"
    echo ""
    echo "  \${CYAN}status\${RESET}          État des services"
    echo "  \${CYAN}logs [service]\${RESET}  Logs en direct"
    echo "  \${CYAN}update\${RESET}          Met à jour les images"
    echo "  \${CYAN}model\${RESET}           Change le modèle LLM"
    echo "  \${CYAN}start\${RESET}           Démarre les services"
    echo "  \${CYAN}stop\${RESET}            Arrête les services"
    echo "  \${CYAN}restart\${RESET}         Redémarre les services"
}

case "\${1:-help}" in
    status)  cmd_status       ;;
    logs)    cmd_logs "\${2:-}" ;;
    update)  cmd_update       ;;
    model)   cmd_model        ;;
    start)   cmd_start        ;;
    stop)    cmd_stop         ;;
    restart) cmd_restart      ;;
    *)       cmd_help         ;;
esac
CLISCRIPT

sudo mv /tmp/tinai-generated /usr/local/bin/tinai
sudo chmod +x /usr/local/bin/tinai
echo "✅ CLI tinai installé → tinai help"

# ── Lancement ─────────────────────────────────────────────────────
if [ "${CI:-}" != "true" ]; then
    echo "🚀 Lancement de TinAI..."
    docker compose up -d
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║         🎉 TinAI v2 est prêt !               ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║  CLI : tinai status / logs / model / update  ║"
    echo "╚══════════════════════════════════════════════╝"
    tinai status
fi
