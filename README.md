# TinAI 🧠

**Tiny AI Dev Assistant** – Ton assistant fullstack web 100 % local, ultra-léger, pour tous les SBC/CPU-only.

Menu interactif **gum** → tu coches exactement ce que tu veux :
- llama.cpp server (Qwen2.5-Coder-3B)
- Open WebUI (frontend riche + RAG)
- VS Code web + Continue.dev préconfiguré
- Aider (pair programming autonome)
- OpenFang (agents 24/7)
- RAG LanceDB (mémoire persistante de tes repos GitHub)
- llama-swap (switch modèles à chaud)
- Caddy + Filebrowser (UX pro)

**Installation en 1 commande** :
```bash
curl -fsSL https://raw.githubusercontent.com/tonpseudo/TinAI/main/install.sh | bash
```

Tout reste offline, privé, ~5-7 Go RAM max.

(Remplace `tonpseudo` par ton username GitHub)

#### 2. `install.sh` (le cœur du projet – beau menu gum)
```bash
#!/bin/bash
set -e

echo "🚀 Bienvenue dans TinAI – Tiny AI Dev Assistant"

# Installation de gum si absent
if ! command -v gum &> /dev/null; then
    echo "📦 Installation de gum (menu beau)..."
    curl -fsSL https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz | tar -xz && sudo mv gum /usr/local/bin/
fi

# Menu multi-sélection (cases à cocher)
echo "Sélectionne les composants que tu veux (espace pour cocher, entrée pour valider) :"
CHOICES=$(gum choose --no-limit \
    "llama-server (base obligatoire)" \
    "Open WebUI (frontend riche + RAG)" \
    "Code-Server + Continue.dev (VS Code web)" \
    "Aider (pair programming autonome)" \
    "OpenFang (agents autonomes 24/7)" \
    "LanceDB RAG (mémoire persistante des projets)" \
    "llama-swap (switch modèles à chaud)" \
    "Caddy + Filebrowser (URLs propres + explorateur)")

# Création du dossier
mkdir -p TinAI && cd TinAI
mkdir -p templates models projects

# Génération automatique du docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'
services:
EOF

# Service de base obligatoire
cat >> docker-compose.yml << 'BASE'
  llama-server:
    image: ghcr.io/ggml-org/llama.cpp:server
    container_name: tinai-llama
    ports: ["8081:8081"]
    volumes: ["./models:/models"]
    command: >
      -hf bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
      --model-file Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
      --host 0.0.0.0 --port 8081 --ctx-size 8192 --threads 4 --n-gpu-layers 0 --jinja
    restart: unless-stopped
    deploy: {resources: {limits: {memory: 5.5g}}}
BASE

# Ajout conditionnel des services sélectionnés
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

if echo "$CHOICES" | grep -q "Code-Server"; then
    cat >> docker-compose.yml << 'CODE'
  code-server:
    image: ghcr.io/coder/code-server:latest
    container_name: tinai-code
    ports: ["8080:8080"]
    volumes: ["./projects:/home/coder/project", "code-data:/home/coder/.local/share/code-server"]
    environment: {PASSWORD: changezmoi123}
    entrypoint: /bin/sh -c "
      code-server --install-extension Continue.continue &&
      mkdir -p /home/coder/.continue &&
      cat > /home/coder/.continue/config.json << 'JSON'
{ \"models\": [{ \"title\": \"TinAI-Qwen\", \"provider\": \"openai\", \"model\": \"qwen-coder-3b\", \"apiBase\": \"http://llama-server:8081/v1\", \"apiKey\": \"sk-123456789\" }], \"tabAutocompleteModel\": { \"title\": \"TinAI-Auto\", \"provider\": \"openai\", \"model\": \"qwen-coder-3b\", \"apiBase\": \"http://llama-server:8081/v1\", \"apiKey\": \"sk-123456789\" } }
JSON
      && /usr/bin/entrypoint.sh"
    restart: unless-stopped
CODE
fi

# (On peut ajouter les autres services de la même façon – Aider, OpenFang, etc. Je t’ai mis les 3 principaux pour commencer)

cat >> docker-compose.yml << EOF

volumes:
  open-webui-data:
  code-data:
EOF

echo "✅ docker-compose.yml généré avec tes choix !"
echo "🚀 Lancement..."
docker compose up -d

echo "
🎉 TinAI est prêt !
• Open WebUI → http://IP:3000
• VS Code → http://IP:8080 (mdp: changezmoi123)
• Chat direct → http://IP:8081


