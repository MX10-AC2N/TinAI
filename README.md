<div align="center">

# 🛠️ WIP 🛠️

# 🧠 TinAI

**Local AI stack — 100% offline, CPU-only, two focused Docker containers.**  
**Stack IA locale — 100 % offline, CPU only, deux conteneurs Docker dédiés.**

[![CI-TinAI](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-orange.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-4.0.0-blue)](https://github.com/MX10-AC2N/TinAI/releases)
[![Docker](https://img.shields.io/badge/docker-ghcr.io-2496ED?logo=docker)](https://ghcr.io/MX10-AC2N/tinai)
[![OpenFang](https://img.shields.io/badge/OpenFang-pre--1.0-brightgreen)](https://openfang.sh)
[![llama.cpp](https://img.shields.io/badge/llama.cpp-latest-orange)](https://github.com/ggml-org/llama.cpp)
[![Open WebUI](https://img.shields.io/badge/Open_WebUI-latest-blue)](https://github.com/open-webui/open-webui)

[🇫🇷 Français](#-démarrage-rapide) · [🇬🇧 English](#-quick-start-english)

</div>

---

## 🖼️ Screenshots / Captures d'écran

<div align="center">

| Open WebUI Chat | OpenFang Dashboard | API Terminal |
|---|---|---|
| ![Open WebUI](docs/screenshots/webui-placeholder.png) | ![OpenFang](docs/screenshots/openfang-placeholder.png) | ![API](docs/screenshots/api-placeholder.png) |
| *Interface de chat – Open WebUI (port 3000)* | *Agents autonomes (port 4200)* | *API OpenAI-compatible (port 8081)* |

> 📸 *Placeholders — remplace ces images par des captures réelles dans `docs/screenshots/`*

</div>

---

## 🇫🇷 Démarrage rapide

```bash
# 1. Cloner le projet
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI

# 2. (Optionnel) Personnaliser
cp .env.example .env && nano .env

# 3. Build & lancement
docker compose up --build
```

Le modèle **Qwen3-1.7B** (~1.4 GB) est téléchargé automatiquement au premier démarrage.

**Services disponibles :**

| Service | URL | Description |
|---|---|---|
| 🌐 **Open WebUI** | http://localhost:3000 | Interface de chat |
| 🤖 **OpenFang** | http://localhost:4200 | Dashboard agents IA autonomes |
| ⚡ **llama-server** | http://localhost:8081 | API OpenAI-compatible |

---

## 🇬🇧 Quick Start (English)

```bash
# 1. Clone the project
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI

# 2. (Optional) Customize
cp .env.example .env && nano .env

# 3. Build & start
docker compose up --build
```

The **Qwen3-1.7B** model (~1.4 GB) downloads automatically on first start.

**Available services:**

| Service | URL | Description |
|---|---|---|
| 🌐 **Open WebUI** | http://localhost:3000 | Chat interface |
| 🤖 **OpenFang** | http://localhost:4200 | Autonomous AI agents dashboard |
| ⚡ **llama-server** | http://localhost:8081 | OpenAI-compatible API |

---

## 🔒 Sécurité / Security

> ⚠️ **IMPORTANT — Avant toute exposition réseau / Before any network exposure:**

```bash
# FR: Génère des clés sécurisées dans .env
# EN: Generate secure keys in .env
TINAI_API_KEY=$(openssl rand -hex 32)
WEBUI_SECRET_KEY=$(openssl rand -hex 32)
```

Ne déploie jamais avec les valeurs par défaut `sk-tinai` / `tinai-secret-change-me` sur un réseau public.  
*Never deploy with default values `sk-tinai` / `tinai-secret-change-me` on a public network.*

---

## 📦 Exemples d'utilisation / Usage Examples

### 💬 Chat API (cURL)

```bash
# FR: Requête simple au modèle
# EN: Simple model request
curl http://localhost:8081/v1/chat/completions \
  -H "Authorization: Bearer ${TINAI_API_KEY:-sk-tinai}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinai",
    "messages": [
      {"role": "system", "content": "Tu es un assistant utile."},
      {"role": "user",   "content": "Explique Docker en 3 phrases."}
    ],
    "stream": false
  }'
```

### 🔄 Streaming

```bash
curl http://localhost:8081/v1/chat/completions \
  -H "Authorization: Bearer ${TINAI_API_KEY:-sk-tinai}" \
  -H "Content-Type: application/json" \
  -d '{"model":"tinai","messages":[{"role":"user","content":"Hello!"}],"stream":true}'
```

### 🐍 Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8081/v1",
    api_key="sk-tinai",  # remplace par ta vraie clé
)

response = client.chat.completions.create(
    model="tinai",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user",   "content": "What is llama.cpp?"},
    ],
)
print(response.choices[0].message.content)
```

### 🟨 JavaScript / Node.js

```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "http://localhost:8081/v1",
  apiKey: "sk-tinai",
});

const chat = await client.chat.completions.create({
  model: "tinai",
  messages: [{ role: "user", content: "Bonjour !" }],
});
console.log(chat.choices[0].message.content);
```

### 🤖 OpenFang — Agent OS autonome

OpenFang est un **Agent OS** en Rust avec 7 agents autonomes (Hands), 40 canaux de messagerie, 27 providers LLM et 16 couches de sécurité. Dans TinAI il utilise **llama-server local** comme LLM par défaut.

```bash
# Activer un agent autonome (Hands)
docker compose exec tinai openfang hand activate researcher
docker compose exec tinai openfang hand activate lead
docker compose exec tinai openfang hand list

# Voir le statut des agents
docker compose exec tinai openfang hand status researcher

# Chat direct en CLI
docker compose exec tinai openfang chat

# API OpenAI-compatible
curl http://localhost:4200/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-tinai" \
  -d '{"model":"qwen3-1.7b","messages":[{"role":"user","content":"Analyse les tendances IA de 2025"}]}'
```

> 💡 La config OpenFang est dans `./data/openfang/config.toml` — générée automatiquement au 1er démarrage.  
> Voir [openfang.sh/docs/configuration](https://www.openfang.sh/docs/configuration) pour les 62 variables disponibles.

### 🖥️ Intégration VS Code

Installe l'extension **Continue** ([marketplace](https://marketplace.visualstudio.com/items?itemName=Continue.continue)) puis ajoute dans `~/.continue/config.json` :

```json
{
  "models": [
    {
      "title": "TinAI (local)",
      "provider": "openai",
      "model": "tinai",
      "apiBase": "http://localhost:8081/v1",
      "apiKey": "sk-tinai"
    }
  ]
}
```

---

## ⚙️ Configuration `.env`

| Variable | Défaut | Description |
|---|---|---|
| `LLAMA_HF_REPO` | `Qwen/Qwen3-1.7B-GGUF` | Repo HuggingFace du modèle |
| `LLAMA_HF_FILE` | `qwen3-1.7b-q5_k_m.gguf` | Fichier GGUF |
| `LLAMA_CTX_SIZE` | `8192` | Contexte en tokens |
| `LLAMA_THREADS` | `4` | Threads CPU (= cœurs physiques) |
| `LLAMA_GPU_LAYERS` | `0` | `0` = CPU only, `-1` = tout GPU |
| `MEM_LIMIT` | `6g` | RAM max du conteneur **tinai** (backend) |
| `WEBUI_MEM_LIMIT` | `3g` | RAM max du conteneur **webui** |
| `TINAI_API_KEY` | `sk-tinai` | ⚠️ **À changer !** |
| `WEBUI_SECRET_KEY` | `tinai-secret-change-me` | ⚠️ **À changer !** |

### 🔄 Multi-modèles supportés

| Modèle | Repo HF | Fichier | RAM |
|---|---|---|---|
| **Qwen3-1.7B** (défaut) | `Qwen/Qwen3-1.7B-GGUF` | `qwen3-1.7b-q5_k_m.gguf` | ~3 GB |
| **Phi-3 Mini** | `microsoft/Phi-3-mini-4k-instruct-gguf` | `Phi-3-mini-4k-instruct-q4.gguf` | ~3 GB |
| **Mistral 7B** | `TheBloke/Mistral-7B-Instruct-v0.2-GGUF` | `mistral-7b-instruct-v0.2.Q4_K_M.gguf` | ~5 GB |
| **Gemma 2B** | `bartowski/gemma-2-2b-it-GGUF` | `gemma-2-2b-it-Q5_K_M.gguf` | ~3 GB |

Exemple pour passer à Phi-3 :
```dotenv
LLAMA_HF_REPO=microsoft/Phi-3-mini-4k-instruct-gguf
LLAMA_HF_FILE=Phi-3-mini-4k-instruct-q4.gguf
```

---

## 🗂️ Utiliser son propre modèle

```bash
# Place le fichier dans ./models/
cp ~/Downloads/mon-modele.gguf ./models/

# Mets à jour .env
echo "LLAMA_HF_FILE=mon-modele.gguf" >> .env

# Redémarre le backend
docker compose restart tinai
```

---

## 🔧 Commandes utiles / Useful commands

```bash
# Logs en temps réel (tous les conteneurs)
docker compose logs -f

# Logs par conteneur
docker compose logs -f tinai
docker compose logs -f webui

# Logs des services internes (backend)
docker compose exec tinai tail -f /var/log/tinai/llama.log
docker compose exec tinai tail -f /var/log/tinai/openfang.log

# Statut des services internes (supervisord)
docker compose exec tinai supervisorctl status

# Redémarrer un service individuel
docker compose exec tinai supervisorctl restart llama
docker compose exec tinai supervisorctl restart openfang

# Redémarrer un conteneur entier
docker compose restart tinai
docker compose restart webui

# Monitoring ressources
docker stats tinai tinai-webui

# Arrêter / Relancer
docker compose down
docker compose up -d

# Rebuild complet
docker compose down && docker compose up --build
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────┐   ┌──────────────────────────┐
│  Conteneur  tinai               │   │  Conteneur  tinai-webui  │
│  (Dockerfile)                   │   │  (Dockerfile.webui)      │
│                                 │   │                          │
│  ┌─────────────────────────┐   │   │  ┌────────────────────┐  │
│  │  llama-server  :8081    │◄──┼───┼──┤  Open WebUI  :8080 │  │
│  │  ~32 MB · C/C++         │   │   │  │  Python 3.11       │  │
│  └─────────────────────────┘   │   │  └────────────────────┘  │
│  ┌─────────────────────────┐   │   └──────────────────────────┘
│  │  OpenFang  :4200        │   │           port 3000 (host)
│  │  ~32 MB · Rust          │   │
│  │  7 Hands · 40 canaux    │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
         ports 4200, 8081 (host)
              tinai-net (bridge)

Volumes :
  ./models          → tinai:/data/models           (fichiers .gguf)
  ./data/openfang   → tinai:/root/.openfang         (config + agents)
  ./data/webui      → tinai-webui:/app/backend/data (BDD Open WebUI)
```

**Pourquoi deux conteneurs ?**  
Open WebUI est une application Python lourde (~2-3 GB d'image). La séparer du backend `tinai` (Debian slim + 2 binaires) permet à chaque conteneur de démarrer, redémarrer et scaler indépendamment, et évite que le temps de démarrage de l'un ne bloque l'autre.

---

## 📋 Configuration requise / Requirements

| | Minimum | Recommandé |
|---|---|---|
| **RAM** | 4 GB | 8 GB |
| **CPU** | x86_64 / ARM64 | 4+ cœurs |
| **Disque** | 5 GB | 10 GB |
| **Docker** | 24.0+ | latest |
| **OS** | Linux, macOS, Windows (WSL2) | Linux |

> 🍓 Compatible Raspberry Pi 4/5 (ARM64), Apple Silicon (Rosetta 2)

---

## 🚀 CI / Pipeline

**3 jobs automatiques à chaque push sur `main` :**

1. **🔒 Audit sécurité** — ShellCheck, secrets hardcodés, `.gitignore`, ports via variables, présence de `Dockerfile.webui`
2. **🧪 Build & Test** — Matrice `amd64` + `arm64` en parallèle, build des **deux images**, démarrage séquencé (`tinai` puis `webui`), tests des 3 services
3. **📋 Rapport consolidé** — [`TEST-REPORT.md`](./TEST-REPORT.md) committé automatiquement

---

## 🤝 Contribuer / Contributing

Voir [CONTRIBUTING.md](./CONTRIBUTING.md) · See [CONTRIBUTING.md](./CONTRIBUTING.md)

---

## 📄 Licence / License

[MIT](./LICENSE) — MX10-AC2N

---

<div align="center">

**Built with ❤️ using [llama.cpp](https://github.com/ggml-org/llama.cpp) · [Open WebUI](https://github.com/open-webui/open-webui) · [OpenFang](https://openfang.sh)**

</div>
