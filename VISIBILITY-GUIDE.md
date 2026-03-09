# TinAI – Guide de visibilité GitHub

## Topics GitHub recommandés

À ajouter dans : **Settings → Topics** de ton repo GitHub

```
docker
llm
llama-cpp
open-webui
openfang
offline-ai
cpu-only
self-hosted
ai-stack
raspberry-pi
```

## Publication de l'image Docker (GHCR)

```bash
# 1. Aller dans Actions → "Build & Publish – GHCR"
# 2. Cliquer "Run workflow"
# 3. Sélectionner le modèle, le tag et les architectures
# 4. Lancer

# Une fois publié, les utilisateurs peuvent faire :
docker pull ghcr.io/TON-USERNAME/tinai:latest
TINAI_IMAGE=ghcr.io/TON-USERNAME/tinai:latest docker compose up -d
```

## Posts de promotion

### Reddit — r/selfhosted

```
**TinAI – Local AI stack: llama.cpp + Open WebUI + OpenFang in one Docker container**

Just released TinAI v3.1 – a single Docker image that bundles:
- 🦙 llama.cpp server (OpenAI-compatible API)
- 🌐 Open WebUI (chat interface)
- 🤖 OpenFang (autonomous AI agents with 40 channel adapters)
- 📦 Qwen3-1.7B out of the box, swap any GGUF model

100% offline, CPU-only, ~3-4 GB RAM. Works on Raspberry Pi 4/5!

GitHub: https://github.com/MX10-AC2N/TinAI

`docker compose up --build` and you're done.
```

### Reddit — r/LocalLLaMA

```
**TinAI: One-command local AI with llama.cpp + Open WebUI + OpenFang agents**

Tired of setting up each component separately? TinAI does it all:

Single Docker container running:
- llama.cpp server with Qwen3-1.7B (auto-downloaded)
- Open WebUI for a ChatGPT-like experience
- OpenFang for autonomous agents (researcher, lead gen, twitter bot, etc.)

Multi-arch: amd64 + arm64. CI tested on both.

https://github.com/MX10-AC2N/TinAI
```

### X / Twitter

```
🚀 TinAI v3.1 – Run your own AI stack locally with ONE command:

docker compose up --build

✅ llama.cpp + Open WebUI + OpenFang
✅ 100% offline, CPU-only
✅ Qwen3-1.7B included
✅ Works on Raspberry Pi!

#LocalAI #Docker #OpenSource #llama #SelfHosted

👉 https://github.com/MX10-AC2N/TinAI
```

### Hacker News (Show HN)

```
Show HN: TinAI – llama.cpp + Open WebUI + OpenFang in a single Docker container

I built TinAI to make local AI setup trivial. One `docker compose up` gives you:
- A llama.cpp server with OpenAI-compatible API
- Open WebUI for chat
- OpenFang for autonomous agents (it's an Agent OS in Rust)

Works offline, CPU-only, 3-4 GB RAM. Multi-arch (amd64 + arm64).

https://github.com/MX10-AC2N/TinAI
```
