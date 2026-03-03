# TinAI 🧠

[![CI – TinAI v2 Deploy & Test](https://github.com/MX10-AC2N/TinAI/actions/workflows/docker%E2%80%91ci%E2%80%91test%E2%80%91report.yml/badge.svg)](https://github.com/MX10-AC2N/TinAI/actions/workflows/docker%E2%80%91ci%E2%80%91test%E2%80%91report.yml)
[![TEST-REPORT](https://img.shields.io/badge/test--report-voir%20les%20résultats-blue)](./TEST-REPORT.md)
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

```bash
cp .env.example .env
```

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
MODELS_DIR=./models              # Modèles GGUF
PROJECTS_DIR=./projects          # Tes projets (VS Code + Aider)
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

> Le `.env` est automatiquement lu par `install.sh` et le CLI `tinai`.

---

## Menu interactif

Au lancement, un menu **gum** te permet de cocher exactement ce que tu veux :

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

| Service | Description | Port défaut | RAM |
|---------|-------------|-------------|-----|
| **llama-server** | Moteur LLM – Qwen2.5-Coder-3B (base obligatoire) | `8081` | ~3 GB |
| **Open WebUI** | Frontend chat riche + RAG intégré | `3000` | ~500 MB |
| **SillyTavern** | Frontend créatif – roleplay, personas, scénarios | `8008` | ~200 MB |
| **Code-Server** | VS Code dans le navigateur + Continue.dev préconfiguré | `8080` | ~500 MB |
| **Aider** | Pair programming autonome en CLI | – | ~100 MB |
| **OpenFang** | Agent OS autonome 24/7 – 7 Hands prêts à l'emploi | `4200` | ~200 MB |
| **Embeddings** | nomic-embed-text-v1.5 dédié au RAG | `8084` | ~500 MB |
| **Qdrant** | Base vectorielle pour RAG + dashboard web | `6333` | ~200 MB |
| **Vision** | LLaVA-Phi-3-mini – analyse d'images + texte | `8085` | ~2.2 GB |
| **ComfyUI** | Génération d'images locale (CPU) | `7860` | ~2 GB |
| **llama-swap** | Switch de modèles à chaud sans redémarrer | `11434` | ~50 MB |
| **Caddy** | Reverse proxy – URLs propres pour tous les services | `80` | ~30 MB |
| **Filebrowser** | Explorateur de fichiers web pour `./projects` | `8083` | ~50 MB |

---

## Accès rapides après installation

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

> Les ports sont ceux par défaut. Si tu les as changés dans `.env`, adapte en conséquence.

---

## CLI `tinai`

Installé automatiquement par `install.sh` dans `/usr/local/bin/tinai`.  
Lit le `.env` automatiquement pour respecter tes ports et paramètres personnalisés.

```bash
# État de tous les services + consommation RAM/CPU
tinai status

# Logs en direct d'un service (menu interactif si omis)
tinai logs
tinai logs llama-server

# Changer de modèle LLM à chaud
tinai model

# Mettre à jour toutes les images Docker
tinai update

# Démarrer / Arrêter / Redémarrer
tinai start
tinai stop
tinai restart
```

### `tinai model` – Modèles disponibles

| Modèle | Usage | Taille |
|--------|-------|--------|
| Qwen2.5-Coder-3B | Coding (défaut) | 2.2 GB |
| Qwen2.5-Coder-7B | Coding puissant | 4.8 GB |
| LLaVA-Phi-3-mini | Vision + texte | 2.2 GB |
| Mistral-7B | Généraliste | 4.1 GB |
| Phi-3.5-mini | Ultra léger | 2.2 GB |
| DeepSeek-Coder-1.3B | Micro coding | 0.8 GB |

---

## Architecture générée

`install.sh` génère dynamiquement un `docker-compose.yml` avec uniquement les services cochés.  
Rien d'inutile ne tourne.

```
TinAI/
├── docker-compose.yml        ← généré par install.sh
├── models/                   ← modèles GGUF téléchargés automatiquement
├── projects/                 ← tes projets (monté dans VS Code + Aider)
├── comfyui/
│   ├── models/               ← modèles ComfyUI
│   └── output/               ← images générées
├── openfang-config/
│   └── openfang.toml         ← généré si OpenFang sélectionné
├── Caddyfile                 ← généré si Caddy sélectionné
└── llama-swap-config.yaml    ← généré si llama-swap sélectionné
```

---

## CI/CD

Chaque push sur `main` déclenche le workflow GitHub Actions qui :

1. **Compile OpenFang** depuis le source Rust (avec cache entre les runs)
2. **Initialise le `.env`** depuis `.env.example` (ports par défaut)
3. **Génère le `docker-compose.yml`** via `install.sh` en mode CI (tous les services)
4. **Valide la syntaxe** YAML du compose
5. **Vérifie** que tous les services sont bien définis
6. **Démarre** tous les conteneurs
7. **Teste** chaque endpoint HTTP
8. **Committe `TEST-REPORT.md`** dans le repo avec les résultats

→ [Voir le dernier TEST-REPORT.md](./TEST-REPORT.md)

---

## Configuration RAM recommandée

| RAM | Stack conseillée |
|-----|-----------------|
| 4 GB | llama-server + Code-Server |
| 6 GB | + Open WebUI + Qdrant + Embeddings |
| 8 GB | + SillyTavern + OpenFang + llama-swap |
| 12 GB+ | Stack complète avec Vision ou ComfyUI |

---

## Architecture supportée

Détection automatique au lancement :

- `x86_64` — PC, serveur, mini PC
- `aarch64` — Raspberry Pi 4/5, Orange Pi, Radxa
- `armv7l` — Raspberry Pi 3 et équivalents

---

## Repo

```
TinAI/
├── install.sh                  ← installateur principal
├── tinai                       ← CLI de gestion
├── .env.example                ← configuration (ports, répertoires, modèle)
├── TEST-REPORT.md              ← rapport du dernier run CI
└── .github/
    └── workflows/
        └── docker‑ci‑test‑report.yml
```

---

## License

MIT – utilise-le comme tu veux.

---

*Fait avec ❤️ pour les makers, devs indés, et bidouilleurs de SBC.*
