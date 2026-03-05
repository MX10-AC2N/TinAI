## 🧪 TinAI v2 – Test Report (ARM64)

**Date :** 2026-03-05 06:20 UTC
**Run :** [#5](https://github.com/MX10-AC2N/TinAI/actions/runs/22704438782)
**Commit :** `43e956d218e10c6092025ad0570df97af7d1e1b4`
**Branch :** `main`
**Architecture :** `aarch64` (ubuntu-24.04-arm)

### Résultats

| Service | Statut | Endpoint |
|---------|--------|----------|
| Open-WebUI (3000) | ✅ OK | `http://127.0.0.1:3000/` |
| SillyTavern (8008) | ❌ FAIL | `http://127.0.0.1:8008/` |
| Code-Server (8080) | ✅ OK | `http://127.0.0.1:8080/` |
| Embeddings (8084) | ❌ FAIL | `http://127.0.0.1:8084/health` |
| Qdrant (6333) | ✅ OK | `http://127.0.0.1:6333/healthz` |
| Vision (8085) | ❌ FAIL | `http://127.0.0.1:8085/health` |
| llama-swap (11434) | ❌ FAIL | `http://127.0.0.1:11434/health` |
| Caddy (80) | ✅ OK | `http://127.0.0.1:80/` |
| Filebrowser (8083) | ✅ OK | `http://127.0.0.1:8083/` |
| OpenFang (4200) | ❌ FAIL | `http://127.0.0.1:4200/` |
| ComfyUI (7860) | ❌ FAIL | `http://127.0.0.1:7860/system_stats` |
| llama-server (8081) | ✅ Conteneur actif | modèle en dl au 1er run |
| Aider | ✅ Conteneur actif | CLI uniquement |
| CLI `tinai status` | ✅ OK | - |

### État des conteneurs

```
NAME                IMAGE                                     COMMAND                  SERVICE        CREATED          STATUS                            PORTS
tinai-aider         paulgauthier/aider:latest                 "/bin/sh -c 'tail -f…"   aider          13 minutes ago   Up 13 minutes                     
tinai-caddy         caddy:alpine                              "caddy run --config …"   caddy          13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp, 443/udp, 2019/tcp
tinai-code          ghcr.io/coder/code-server:latest          "/usr/bin/entrypoint…"   code-server    13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
tinai-comfyui       alpine:latest                             "sh -c 'sleep infini…"   comfyui        13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:7860->8188/tcp, [::]:7860->8188/tcp
tinai-embeddings    ghcr.io/ggml-org/llama.cpp:server         "/app/llama-server -…"   embeddings     13 minutes ago   Restarting (255) 7 seconds ago    
tinai-filebrowser   filebrowser/filebrowser:latest            "tini -- /init.sh"       filebrowser    13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:8083->80/tcp, [::]:8083->80/tcp
tinai-llama         ghcr.io/ggml-org/llama.cpp:server         "/app/llama-server -…"   llama-server   13 minutes ago   Restarting (255) 12 seconds ago   
tinai-openfang      tinai-openfang:latest                     "openfang start"         openfang       13 minutes ago   Up 13 minutes (unhealthy)         0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-qdrant        qdrant/qdrant:latest                      "./entrypoint.sh"        qdrant         13 minutes ago   Up 13 minutes (unhealthy)         0.0.0.0:6333-6334->6333-6334/tcp, [::]:6333-6334->6333-6334/tcp
tinai-sillytavern   ghcr.io/sillytavern/sillytavern:release   "tini -- ./docker-en…"   sillytavern    13 minutes ago   Restarting (1) 37 seconds ago     
tinai-swap          alpine:latest                             "sh -c 'sleep infini…"   llama-swap     13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:11434->8080/tcp, [::]:11434->8080/tcp
tinai-vision        ghcr.io/ggml-org/llama.cpp:server         "/app/llama-server -…"   vision         13 minutes ago   Restarting (255) 7 seconds ago    
tinai-webui         ghcr.io/open-webui/open-webui:main        "bash start.sh"          open-webui     13 minutes ago   Up 13 minutes (healthy)           0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

### tinai status

```
[1m🧠 TinAI v2.0.0 – État des services[0m
════════════════════════════════════════════
  [1;33m⏳[0m llama-swap     → démarrage en cours (port 11434)
  [0;32m✅[0m Code-Server    → [0;36mhttp://localhost:8080[0m
  [0;31m❌[0m llama-server   → restarting
  [0;31m❌[0m Embeddings     → restarting
  [0;32m✅[0m Caddy          → [0;36mhttp://localhost:80[0m
  [0;32m✅[0m Open WebUI     → [0;36mhttp://localhost:3000[0m
  [1;33m⏳[0m OpenFang       → démarrage en cours (port 4200)
  [0;31m❌[0m SillyTavern    → restarting
  [0;32m✅[0m Filebrowser    → [0;36mhttp://localhost:8083[0m
  [1;33m⏳[0m ComfyUI        → démarrage en cours (port 7860)
  [0;32m✅[0m Qdrant RAG     → [0;36mhttp://localhost:6333[0m
  [0;32m✅[0m Aider          → actif
  [0;31m❌[0m Vision VL      → restarting

[1m💾 Ressources :[0m
tinai-webui        CPU:  0.17%  MEM:  770.1MiB  /  15.58GiB
tinai-openfang     CPU:  0.00%  MEM:  25.49MiB  /  15.58GiB
tinai-aider        CPU:  0.00%  MEM:  732KiB    /  15.58GiB
tinai-caddy        CPU:  0.00%  MEM:  18.85MiB  /  15.58GiB
tinai-sillytavern  CPU:  0.00%  MEM:  0B        /  0B
tinai-comfyui      CPU:  0.00%  MEM:  332KiB    /  4GiB
tinai-filebrowser  CPU:  0.00%  MEM:  18.41MiB  /  15.58GiB
tinai-code         CPU:  0.00%  MEM:  71.29MiB  /  15.58GiB
tinai-llama        CPU:  0.00%  MEM:  0B        /  0B
tinai-vision       CPU:  0.00%  MEM:  0B        /  0B
tinai-swap         CPU:  0.00%  MEM:  328KiB    /  15.58GiB
tinai-embeddings   CPU:  0.00%  MEM:  0B        /  0B
tinai-qdrant       CPU:  0.06%  MEM:  30.84MiB  /  15.58GiB
```

### Notes ARM64
- **Architecture :** runner `ubuntu-24.04-arm` — binaires natifs ARM64
- **llama.cpp** utilise les optimisations NEON/SVE sur ARM64
- **ComfyUI** non disponible sur ARM64 (image `yanwk/comfyui-boot:cpu` x86-only) — optionnel
- **llama-swap** utilise le tag `:latest` (multi-arch) au lieu de `:cpu`
- **llama-server** télécharge Qwen2.5-Coder-3B (~3 GB) au 1er démarrage
- **Vision** utilise LLaVA-Phi-3-mini (1 seul fichier GGUF)
- **OpenFang** buildé depuis source — restart: on-failure
