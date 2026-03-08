# TinAI 🧠

[![CI – TinAI x86_64](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci-x86.yml/badge.svg)](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci-x86.yml)
[![CI – TinAI ARM64](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci-arm64.yml/badge.svg)](https://github.com/MX10-AC2N/TinAI/actions/workflows/ci-arm64.yml)
[![TEST-REPORT x86](https://img.shields.io/badge/test--report-x86__64-blue)](./TEST-REPORT.md)
[![TEST-REPORT ARM64](https://img.shields.io/badge/test--report-arm64-blueviolet)](./TEST-REPORT-arm64.md)
[![Version](https://img.shields.io/badge/version-2.0.0-green)](https://github.com/MX10-AC2N/TinAI/releases)
[![License](https://img.shields.io/badge/license-MIT-orange)](./LICENSE)

**Tiny AI Dev Assistant** – Stack IA locale complète, modulaire, ultra-légère.  
Un seul script. Un menu interactif. Tu coches ce que tu veux. C'est prêt.

Conçu pour tourner sur n'importe quel CPU-only : Raspberry Pi, Orange Pi, mini PC, vieux laptop.  
Tout reste **100 % offline, privé, ~5–7 GB RAM max**.

---

## Installation en 1 commande

```bash
curl -fsSL https://raw.githubusercontent.com/MX10-AC2N/TinAI/main/install.sh | bash
```

### Installation personnalisée (ports, répertoires, modèle)

```bash
# 1. Cloner le repo
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI

# 2. Configurer (optionnel)
cp .env.example .env
nano .env

# 3. Installer
./install.sh
```

---

## Configuration `.env`

Toutes les valeurs sont optionnelles — les défauts fonctionnent out-of-the-box.

### Ports

```dotenv
PORT_LLAMA=8081        # API LLM principale
PORT_WEBUI=3000        # Open WebUI
PORT_CODE=8080         # VS Code web
PORT_SILLYTAVERN=8008  # SillyTavern
PORT_OPENFANG=4200     # OpenFang agents
PORT_EMBEDDINGS=8084   # Embeddings RAG
PORT_QDRANT=6333       # Qdrant REST
PORT_VISION=8085       # Vision LLaVA
PORT_COMFYUI=7860      # ComfyUI images
PORT_SWAP=11434        # llama-swap
PORT_CADDY=80          # Reverse proxy
PORT_FILEBROWSER=8083  # Explorateur fichiers
```

### Répertoires

```dotenv
MODELS_DIR=./models
PROJECTS_DIR=./projects
COMFYUI_MODELS_DIR=./comfyui/models
COMFYUI_OUTPUT_DIR=./comfyui/output
OPENFANG_CONFIG_DIR=./openfang-config
```

### Modèle & paramètres LLM

```dotenv
LLAMA_HF_REPO=bartowski/Qwen2.5-Coder-3B-Instruct-GGUF
LLAMA_HF_FILE=Qwen2.5-Coder-3B-Instruct-Q5_K_M.gguf
LLAMA_CTX_SIZE=8192
LLAMA_THREADS=4
LLAMA_MEM_LIMIT=5.5g
```

---

## Menu interactif

```
👇 Coche les composants (espace = cocher, entrée = valider)
   RAM disponible : 8.0 GB

  ◉ llama-server (base obligatoire)
  ◉ Open WebUI (frontend riche + RAG)
  ◯ SillyTavern (frontend créatif)
  ◉ Code-Server + Continue.dev (VS Code web)
  ◯ Aider (pair programming autonome)
  ◯ OpenFang (agents autonomes 24/7)
  ◉ Embedding dédié – nomic-embed-text (RAG propre)
  ◉ Qdrant RAG (mémoire persistante des projets)
  ◯ Multimodal – LLaVA-Phi-3-mini (vision + texte)
  ◯ ComfyUI (génération d'images locale)
  ◯ llama-swap (switch modèles à chaud)
  ◯ Caddy + Filebrowser (URLs propres + explorateur)
```

---

## Services disponibles

| Service | Description | Port | RAM |
|---------|-------------|------|-----|
| **llama-server** | Moteur LLM (base obligatoire) | `8081` | ~3 GB |
| **Open WebUI** | Frontend chat riche + RAG intégré | `3000` | ~500 MB |
| **SillyTavern** | Frontend créatif – roleplay, personas | `8008` | ~200 MB |
| **Code-Server** | VS Code web + Continue.dev | `8080` | ~500 MB |
| **Aider** | Pair programming autonome CLI | – | ~100 MB |
| **OpenFang** | Agent OS autonome 24/7 | `4200` | ~200 MB |
| **Embeddings** | nomic-embed-text-v1.5 pour RAG | `8084` | ~500 MB |
| **Qdrant** | Base vectorielle + dashboard | `6333` | ~200 MB |
| **Vision** | LLaVA-Phi-3-mini – images + texte | `8085` | ~2.2 GB |
| **ComfyUI** | Génération d'images locale (CPU) | `7860` | ~2 GB |
| **llama-swap** | Switch de modèles à chaud | `11434` | ~50 MB |
| **Caddy** | Reverse proxy + URLs propres | `80` | ~30 MB |
| **Filebrowser** | Explorateur de fichiers web | `8083` | ~50 MB |

> **SillyTavern** est un frontend Node.js léger (~200 MB RAM). Il ne fait pas d'inférence LLM : il délègue à llama-server via l'API OpenAI-compatible. La recommandation GPU sur le site officiel concerne l'inférence, pas ST lui-même — il est parfaitement adapté à TinAI.

---

## Accès rapides

| Service | URL |
|---------|-----|
| Open WebUI | http://IP:3000 |
| SillyTavern | http://IP:8008 |
| VS Code | http://IP:8080 · mdp : `changezmoi123` |
| OpenFang | http://IP:4200 |
| ComfyUI | http://IP:7860 |
| Filebrowser | http://IP:8083 |
| llama-server API | http://IP:8081/v1 |
| Embeddings API | http://IP:8084/v1 |
| Vision API | http://IP:8085/v1 |
| Qdrant dashboard | http://IP:6333/dashboard |
| llama-swap | http://IP:11434 |

---

## CLI `tinai`

```bash
tinai status          # État de tous les services + RAM/CPU
tinai logs            # Logs en direct (menu interactif)
tinai logs llama-server
tinai model           # Changer de modèle LLM à chaud
tinai update          # Mettre à jour toutes les images Docker
tinai start / stop / restart
```

### Modèles disponibles

| Modèle | Usage | Taille | Notes |
|--------|-------|--------|-------|
| Qwen2.5-Coder-3B | Coding (défaut) | 2.2 GB | Bon équilibre perf/RAM |
| Qwen2.5-Coder-7B | Coding puissant | 4.8 GB | 8 GB RAM min |
| **Qwen3-0.8B** | Ultra-léger | ~0.5 GB | Idéal Pi/ARM, très rapide |
| **Qwen3-2B** | Léger polyvalent | ~1.2 GB | Bon choix ARM 4 GB |
| LLaVA-Phi-3-mini | Vision + texte | 2.2 GB | |
| Mistral-7B | Généraliste | 4.1 GB | |
| Phi-3.5-mini | Ultra léger | 2.2 GB | |
| DeepSeek-Coder-1.3B | Micro coding | 0.8 GB | |

> **Qwen3-0.8B et Qwen3-2B** sont d'excellents choix pour les machines contraintes. Qwen3-0.8B tourne avec 2 GB de RAM, Qwen3-2B avec 4 GB — tous deux très adaptés à l'ARM.

---

## Architecture générée

```
TinAI/
├── docker-compose.yml        ← généré par install.sh
├── models/                   ← modèles GGUF
├── projects/                 ← tes projets (VS Code + Aider)
├── comfyui/models/ et output/
├── openfang-config/
├── Caddyfile                 ← si Caddy sélectionné
└── llama-swap-config.yaml    ← si llama-swap sélectionné
```

---

## CI/CD

Deux workflows déclenchés manuellement (`workflow_dispatch`) :

### 🖥️ CI x86_64 — `docker‑ci‑test‑report.yml`

Runner : `ubuntu-latest`

- Build/restore OpenFang depuis source (cache → `openfang-version-x86.txt`)
- Génère le compose, démarre tous les services, teste chaque endpoint
- Committe `TEST-REPORT.md` + `openfang-version-x86.txt`

→ [TEST-REPORT.md](./TEST-REPORT.md)

### 🦾 CI ARM64 — `docker-ci-test-report-arm64.yml`

Runner : `ubuntu-24.04-arm` (runner GitHub-hosted ARM64 natif)

- Cache séparé → `openfang-version-arm64.txt`
- **llama-swap** et **ComfyUI** : images x86-only, remplacées par placeholders `alpine` (optionnels dans les tests)
- llama.cpp avec optimisations NEON/SVE ARM64 natives
- Committe `TEST-REPORT-arm64.md` + `openfang-version-arm64.txt`

→ [TEST-REPORT-arm64.md](./TEST-REPORT-arm64.md)

---

## Compatibilité ARM64

| Service | ARM64 | Notes |
|---------|-------|-------|
| llama-server | ✅ Natif | Optimisations NEON/SVE |
| Open WebUI | ✅ | Multi-arch |
| SillyTavern | ✅ | Node.js, multi-arch |
| Code-Server | ✅ | Multi-arch |
| Embeddings, Qdrant, Vision | ✅ | Multi-arch |
| Aider | ✅ | Python, multi-arch |
| Caddy, Filebrowser | ✅ | Multi-arch |
| llama-swap | ⚠️ x86-only | Placeholder alpine en CI ARM64 |
| ComfyUI | ⚠️ x86-only | Placeholder alpine en CI ARM64 |

---

## Configuration RAM recommandée

| RAM | Stack conseillée |
|-----|-----------------|
| 2 GB | llama-server (Qwen3-0.8B) seul |
| 4 GB | + Open WebUI + Qdrant + Embeddings (Qwen3-2B) |
| 6 GB | + SillyTavern + llama-swap (Qwen2.5-3B) |
| 8 GB | Stack complète (Qwen2.5-7B) |
| 12 GB+ | + Vision ou ComfyUI |

---

## Architectures supportées

- `x86_64` — PC, serveur, mini PC
- `aarch64` — Raspberry Pi 4/5, Orange Pi, Radxa
- `armv7l` — Raspberry Pi 3 et équivalents

---

## Structure du repo

```
TinAI/
├── install.sh
├── tinai
├── .env.example
├── TEST-REPORT.md                  ← dernier run CI x86_64
├── TEST-REPORT-arm64.md            ← dernier run CI ARM64
├── openfang-version-x86.txt        ← commit OpenFang x86
├── openfang-version-arm64.txt      ← commit OpenFang ARM64
└── .github/workflows/
    ├── docker‑ci‑test‑report.yml
    └── docker-ci-test-report-arm64.yml
```

---

## License

MIT – utilise-le comme tu veux.

---

*Fait avec ❤️ pour les makers, devs indés, et bidouilleurs de SBC.*
