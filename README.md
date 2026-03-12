<div align="center">

# 🧠 TinAI

**Local AI stack — 100% offline, CPU-only, three focused Docker containers.**  
**Stack IA locale — 100 % offline, CPU only, trois conteneurs Docker dédiés.**

[![CI-TinAI](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-orange.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-5.1.0-blue)](https://github.com/MX10-AC2N/TinAI/releases)
[![Docker](https://img.shields.io/badge/docker-ghcr.io-2496ED?logo=docker)](https://ghcr.io/MX10-AC2N/tinai)
[![OpenFang](https://img.shields.io/badge/OpenFang-pre--1.0-brightgreen)](https://openfang.sh)
[![llama.cpp](https://img.shields.io/badge/llama.cpp-official-orange)](https://github.com/ggml-org/llama.cpp)
[![Open WebUI](https://img.shields.io/badge/Open_WebUI-optional-blue)](https://github.com/open-webui/open-webui)

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

# 2. (Optionnel) Personnaliser les ports, la RAM limite, la clé API…
cp .env.example .env && nano .env

# 3. Déployer
make              # sans Open WebUI
make webui        # avec Open WebUI
make monitoring   # avec dashboard monitoring
```

> 💡 **Sélection du modèle automatique** — si aucun modèle n'est présent dans `./models/`,
> le sélecteur interactif se lance à la fin du déploiement : il interroge HuggingFace en
> temps réel, filtre les modèles CPU-compatibles, affiche les tailles et la RAM nécessaire,
> télécharge ton choix et redémarre `llama-server` automatiquement.
>
> Pour changer de modèle plus tard : `make model`

**Services disponibles :**

| Service | URL | Description |
|---|---|---|
| 💬 **llama WebUI** | http://localhost:8081 | Interface de chat intégrée llama.cpp |
| 🌐 **Open WebUI** | http://localhost:3000 | Interface de chat avancée *(optionnel)* |
| 🤖 **OpenFang** | http://localhost:4200 | Dashboard agents IA autonomes |
| ⚡ **llama API** | http://localhost:8081/v1 | API OpenAI-compatible |
| 📊 **Monitor** | http://localhost:9000 | Dashboard monitoring *(optionnel)* |

---

## 🇬🇧 Quick Start (English)

```bash
# 1. Clone the project
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI

# 2. (Optional) Customize ports, RAM limits, API key…
cp .env.example .env && nano .env

# 3. Deploy
make              # without Open WebUI
make webui        # with Open WebUI
make monitoring   # with monitoring dashboard
```

> 💡 **Automatic model selection** — if no model is present in `./models/`, an interactive
> selector launches at the end of deployment: it queries HuggingFace live, filters
> CPU-compatible models, shows sizes and required RAM, downloads your choice and
> restarts `llama-server` automatically.
>
> To change model later: `make model`

**Available services:**

| Service | URL | Description |
|---|---|---|
| 💬 **llama WebUI** | http://localhost:8081 | Built-in llama.cpp chat interface |
| 🌐 **Open WebUI** | http://localhost:3000 | Advanced chat interface *(optional)* |
| 🤖 **OpenFang** | http://localhost:4200 | Autonomous AI agents dashboard |
| ⚡ **llama API** | http://localhost:8081/v1 | OpenAI-compatible API |
| 📊 **Monitor** | http://localhost:9000 | Monitoring dashboard *(optional)* |

---

## 🛠️ Commandes / Commands

| Commande | Description |
|---|---|
| `make` | Déployer la stack de base |
| `make webui` | + Open WebUI (chat interface) |
| `make monitoring` | + Netdata (monitoring temps réel) |
| `make webui-monitoring` | + Open WebUI + Netdata |
| `make model` | Changer de modèle (sélecteur interactif) |
| `make down` | Arrêter tous les conteneurs |
| `make logs` | Suivre les logs en direct |

---

## 🔒 Sécurité / Security

> ⚠️ **IMPORTANT — Avant toute exposition réseau / Before any network exposure:**

```bash
# FR: Génère des clés sécurisées dans .env
# EN: Generate secure keys in .env
TINAI_API_KEY=$(openssl rand -hex 32)
WEBUI_SECRET_KEY=$(openssl rand -hex 32)
```

Ne déploie jamais avec les valeurs par défaut sur un réseau public.  
*Never deploy with default values on a public network.*

---

## 📦 Exemples d'utilisation / Usage Examples

### 💬 Chat API (cURL)

```bash
curl http://localhost:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinai",
    "messages": [
      {"role": "system", "content": "Tu es un assistant utile."},
      {"role": "user",   "content": "Explique Docker en 3 phrases."}
    ]
  }'
```

### 🐍 Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8081/v1", api_key="sk-tinai")

response = client.chat.completions.create(
    model="tinai",
    messages=[{"role": "user", "content": "What is llama.cpp?"}],
)
print(response.choices[0].message.content)
```

### 🟨 JavaScript / Node.js

```javascript
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:8081/v1", apiKey: "sk-tinai" });
const chat = await client.chat.completions.create({
  model: "tinai",
  messages: [{ role: "user", content: "Bonjour !" }],
});
console.log(chat.choices[0].message.content);
```

### 🖥️ Intégration VS Code (Continue)

Installe l'extension **Continue** puis ajoute dans `~/.continue/config.json` :

```json
{
  "models": [{
    "title": "TinAI (local)",
    "provider": "openai",
    "model": "tinai",
    "apiBase": "http://localhost:8081/v1",
    "apiKey": "sk-tinai"
  }]
}
```

---

## ⚙️ Configuration `.env`

| Variable | Défaut | Description |
|---|---|---|
| `LLAMA_HF_REPO` | `unsloth/Qwen3-1.7B-GGUF` | Repo HuggingFace du modèle |
| `LLAMA_HF_FILE` | `Qwen3-1.7B-Q5_K_M.gguf` | Fichier GGUF à charger |
| `LLAMA_CTX_SIZE` | `8192` | Contexte en tokens |
| `LLAMA_THREADS` | `4` | Threads CPU (= cœurs physiques) |
| `MODELS_DIR` | `./models` | Dossier des modèles sur l'hôte |
| `PORT_LLAMA` | `8081` | Port llama-server |
| `PORT_OPENFANG` | `4200` | Port OpenFang |
| `PORT_WEBUI` | `3000` | Port Open WebUI |
| `WEBUI_SECRET_KEY` | `tinai-secret-change-me` | ⚠️ **À changer !** |

> 💡 Le modèle se choisit interactivement via `make model` — plus besoin d'éditer `.env` à la main.


---

## 📊 Monitoring (optionnel)

```bash
make monitoring          # démarre le dashboard avec la stack
make monitoring-down     # arrête tout y compris le monitoring
```

Le dashboard est disponible sur **http://&lt;ip-zimaboard&gt;:9000** — aucune configuration requise.

Ce qu'il affiche en temps réel (rafraîchissement toutes les 5s) :

- **CPU, RAM, disque** de la machine hôte avec barres de progression
- **État des conteneurs** (`tinai-llama`, `tinai`, `tinai-webui`) avec consommation mémoire
- **Statut llama-server** — modèle chargé, slots libres / en cours
- **Logs en direct** du conteneur `tinai-llama`

> 💡 Peut aussi être activé sur une stack déjà démarrée :
> ```bash
> docker compose --profile monitoring up -d
> ```

> ℹ️ **llama.cpp intègre sa propre WebUI** accessible sur le port 8081 (même port que l'API).  
> Aucune configuration supplémentaire — elle est incluse dans l'image officielle.
---

## 🗂️ Utiliser son propre modèle / Bring your own model

```bash
# Place le fichier dans ./models/
cp ~/Downloads/mon-modele.gguf ./models/

# Lance le sélecteur pour pointer dessus
make model
# → choisis "Entrer un repo manuellement" ou laisse le sélecteur détecter le fichier

# Ou édite .env directement
echo "LLAMA_HF_FILE=mon-modele.gguf" >> .env
docker compose restart llama
```

---

## 🏗️ Architecture

```
┌──────────────────────────┐   ┌──────────────────────────┐   ┌──────────────────────────┐
│  tinai-llama             │   │  tinai                   │   │  tinai-webui  (optionnel)│
│  llama.cpp official img  │   │  Dockerfile              │   │  Open WebUI              │
│                          │   │                          │   │                          │
│  llama-server  :8080 ────┼───►  OpenFang    :4200       │   │  Chat UI       :3000     │
│  (modèle GGUF via HF)    │   │  (Rust agent OS)         │◄──┤  (profile webui)         │
└──────────────────────────┘   └──────────────────────────┘   └──────────────────────────┘
        port 8081 (hôte)               port 4200 (hôte)               port 3000 (hôte)
                              tinai-net (bridge)
```

**Pourquoi trois conteneurs ?**  
Chaque composant a son cycle de vie indépendant. `llama-server` peut redémarrer
pour changer de modèle sans toucher à OpenFang ni à Open WebUI.

---

## 📋 Configuration requise / Requirements

| | Minimum | Recommandé |
|---|---|---|
| **RAM** | 4 GB | 8 GB |
| **CPU** | x86_64 / ARM64 | 4+ cœurs |
| **Disque** | 5 GB | 10 GB |
| **Docker** | 24.0+ | latest |
| **OS** | Linux, macOS, Windows (WSL2) | Linux |

> 🍓 Compatible Raspberry Pi 4/5 (ARM64), Apple Silicon, ZimaBoard 832

---

## 🚀 CI / Pipeline

**3 jobs automatiques à chaque push sur `main` :**

1. **🔒 Audit sécurité** — ShellCheck sur tous les scripts, secrets hardcodés, ports via variables
2. **🧪 Build & Test** — Matrice `amd64` + `arm64` en parallèle, démarrage des conteneurs, tests des services
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
