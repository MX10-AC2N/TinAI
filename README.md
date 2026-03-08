# TinAI v3 🧠

**Un seul conteneur Docker.** llama.cpp + Open WebUI + OpenFang + Qwen3-1.7B.  
100 % offline, CPU-only, ~3–4 GB RAM.

---

## Démarrage rapide

```bash
# 1. Cloner / copier le projet
git clone https://github.com/MX10-AC2N/TinAI.git && cd TinAI

# 2. (Optionnel) Personnaliser
cp .env.example .env && nano .env

# 3. Build & run
docker compose up --build
```

Le modèle **Qwen3-1.7B** est téléchargé automatiquement au premier démarrage (~1.4 GB).

---

## Services inclus

| Service | Port | Description |
|---|---|---|
| **Open WebUI** | `3000` | Interface chat (http://localhost:3000) |
| **OpenFang** | `4200` | Agents IA autonomes |
| **llama-server** | `8081` | API OpenAI-compatible |

---

## Configuration `.env`

| Variable | Défaut | Description |
|---|---|---|
| `LLAMA_HF_REPO` | `Qwen/Qwen3-1.7B-GGUF` | Repo HuggingFace du modèle |
| `LLAMA_HF_FILE` | `qwen3-1.7b-q5_k_m.gguf` | Fichier GGUF à télécharger |
| `LLAMA_CTX_SIZE` | `8192` | Taille de contexte (tokens) |
| `LLAMA_THREADS` | `4` | Threads CPU |
| `LLAMA_GPU_LAYERS` | `0` | Couches GPU (0 = CPU only) |
| `MEM_LIMIT` | `6g` | Limite RAM du conteneur |
| `PORT_WEBUI` | `3000` | Port Open WebUI |
| `PORT_OPENFANG` | `4200` | Port OpenFang |
| `PORT_LLAMA` | `8081` | Port llama-server |
| `TINAI_API_KEY` | `sk-tinai` | Clé API partagée |

---

## Utiliser son propre modèle

Place ton fichier `.gguf` dans `./models/` et modifie `.env` :

```dotenv
LLAMA_HF_FILE=mon-modele.gguf
```

Le fichier sera utilisé directement, sans téléchargement.

---

## Commandes utiles

```bash
# Voir les logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose exec tinai tail -f /var/log/tinai/llama.log
docker compose exec tinai tail -f /var/log/tinai/webui.log
docker compose exec tinai tail -f /var/log/tinai/openfang.log

# Redémarrer un service sans recréer le conteneur
docker compose exec tinai supervisorctl restart webui
docker compose exec tinai supervisorctl restart llama
docker compose exec tinai supervisorctl restart openfang

# Statut des services internes
docker compose exec tinai supervisorctl status

# Arrêter
docker compose down

# Rebuild complet
docker compose down && docker compose up --build
```

---

## API llama-server (OpenAI-compatible)

```bash
curl http://localhost:8081/v1/chat/completions \
  -H "Authorization: Bearer sk-tinai" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3-1.7b",
    "messages": [{"role": "user", "content": "Bonjour !"}]
  }'
```

---

## Architecture

```
┌─────────────────────────────────────────────┐
│  Conteneur TinAI (supervisord)              │
│                                             │
│  ┌──────────────┐  ┌──────────────────────┐│
│  │ llama-server │  │     Open WebUI       ││
│  │  :8081       │◄─┤  :3000               ││
│  │ Qwen3-1.7B   │  │  (chat interface)    ││
│  └──────────────┘  └──────────────────────┘│
│         ▲           ┌──────────────────────┐│
│         └───────────┤     OpenFang         ││
│                     │  :4200 (agents)      ││
│                     └──────────────────────┘│
└─────────────────────────────────────────────┘
       │ volumes
  /data/models    – modèles GGUF
  /data/webui     – base de données WebUI
  /data/openfang  – agents & config
```

---

## Configuration requise

- **RAM** : 3 GB minimum, 4–6 GB recommandé
- **CPU** : x86_64 ou ARM64 (Raspberry Pi 4/5, Apple Silicon via Rosetta)
- **Disque** : ~5 GB (image ~3 GB + modèle ~1.4 GB)
- **Docker** : 24.0+

---

*TinAI v3 – MIT License*
