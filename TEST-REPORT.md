## 🧪 TinAI v2 – Test Report

**Date :** 2026-03-02 22:02 UTC
**Run :** [#8](https://github.com/MX10-AC2N/TinAI/actions/runs/22596991604)
**Commit :** `a98e3cc77abfbbacc52b3dcd65b3b1743fe0bbf9`
**Branch :** `main`

### Résultats

| Service | Statut | Endpoint |
|---------|--------|----------|
| Open-WebUI (3000) | ✅ OK | `http://127.0.0.1:3000/` |
| SillyTavern (8008) | ❌ FAIL | `http://127.0.0.1:8008/` |
| Code-Server (8080) | ✅ OK | `http://127.0.0.1:8080/` |
| OpenFang (4200) | ❌ FAIL | `http://127.0.0.1:4200/` |
| Embeddings (8084) | ✅ OK | `http://127.0.0.1:8084/health` |
| Qdrant (6333) | ✅ OK | `http://127.0.0.1:6333/healthz` |
| Vision (8085) | ✅ OK | `http://127.0.0.1:8085/health` |
| ComfyUI (7860) | ❌ FAIL | `http://127.0.0.1:7860/` |
| llama-swap (11434) | ✅ OK | `http://127.0.0.1:11434/health` |
| Caddy (80) | ✅ OK | `http://127.0.0.1:80/` |
| Filebrowser (8083) | ✅ OK | `http://127.0.0.1:8083/` |
| llama-server (8081) | ✅ Conteneur actif | modèle en dl au 1er run |
| CLI `tinai status` | ✅ OK | - |

### État des conteneurs

```
NAME                IMAGE                                    COMMAND                  SERVICE        CREATED         STATUS                          PORTS
tinai-aider         paulgauthier/aider:latest                "/venv/bin/aider"        aider          7 minutes ago   Restarting (1) 31 seconds ago   
tinai-caddy         caddy:alpine                             "caddy run --config …"   caddy          7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp, 443/udp, 2019/tcp
tinai-code          ghcr.io/coder/code-server:latest         "/usr/bin/entrypoint…"   code-server    7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
tinai-comfyui       ghcr.io/ai-dock/comfyui:latest-cpu       "init.sh"                comfyui        7 minutes ago   Up 7 minutes (unhealthy)        0.0.0.0:7860->7860/tcp, [::]:7860->7860/tcp
tinai-embeddings    ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   embeddings     7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:8084->8084/tcp, [::]:8084->8084/tcp
tinai-filebrowser   filebrowser/filebrowser:latest           "tini -- /init.sh"       filebrowser    7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:8083->80/tcp, [::]:8083->80/tcp
tinai-llama         ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   llama-server   7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-openfang      tinai-openfang:latest                    "openfang start"         openfang       7 minutes ago   Restarting (1) 55 seconds ago   
tinai-qdrant        qdrant/qdrant:latest                     "./entrypoint.sh"        qdrant         7 minutes ago   Up 7 minutes (unhealthy)        0.0.0.0:6333-6334->6333-6334/tcp, [::]:6333-6334->6333-6334/tcp
tinai-sillytavern   ghcr.io/sillytavern/sillytavern:latest   "tini -- ./docker-en…"   sillytavern    7 minutes ago   Up 7 minutes (unhealthy)        0.0.0.0:8008->8000/tcp, [::]:8008->8000/tcp
tinai-swap          ghcr.io/mostlygeek/llama-swap:cpu        "/app/llama-swap -co…"   llama-swap     7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:11434->8080/tcp, [::]:11434->8080/tcp
tinai-vision        ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   vision         7 minutes ago   Up 7 minutes (healthy)          0.0.0.0:8085->8085/tcp, [::]:8085->8085/tcp
tinai-webui         ghcr.io/open-webui/open-webui:main       "bash start.sh"          open-webui     7 minutes ago   Up 6 minutes (healthy)          0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

### tinai status

```
[1m🧠 TinAI v2.0.0 – État des services[0m
════════════════════════════════════════════
  [0;32m✅[0m llama-swap     → [0;36mhttp://localhost:11434[0m
  [0;32m✅[0m Code-Server    → [0;36mhttp://localhost:8080[0m
  [0;32m✅[0m llama-server   → [0;36mhttp://localhost:8081[0m
  [0;32m✅[0m Embeddings     → [0;36mhttp://localhost:8084[0m
  [0;32m✅[0m Caddy          → [0;36mhttp://localhost:80[0m
  [0;32m✅[0m Open WebUI     → [0;36mhttp://localhost:3000[0m
  [0;31m❌[0m OpenFang       → restarting
  [1;33m⏳[0m SillyTavern    → démarrage en cours (port 8008)
  [0;32m✅[0m Filebrowser    → [0;36mhttp://localhost:8083[0m
  [1;33m⏳[0m ComfyUI        → démarrage en cours (port 7860)
  [0;32m✅[0m Qdrant RAG     → [0;36mhttp://localhost:6333[0m
  [0;31m❌[0m Aider          → restarting
  [0;32m✅[0m Vision VL      → [0;36mhttp://localhost:8085[0m

[1m💾 Ressources :[0m
tinai-aider        CPU:  0.00%  MEM:  0B        /  0B
tinai-webui        CPU:  0.16%  MEM:  1.07GiB   /  15.62GiB
tinai-openfang     CPU:  0.00%  MEM:  0B        /  0B
tinai-qdrant       CPU:  0.05%  MEM:  69.02MiB  /  15.62GiB
tinai-llama        CPU:  0.00%  MEM:  413MiB    /  5.5GiB
tinai-vision       CPU:  0.00%  MEM:  2.474GiB  /  4GiB
tinai-caddy        CPU:  0.00%  MEM:  10.52MiB  /  15.62GiB
tinai-sillytavern  CPU:  0.01%  MEM:  190.3MiB  /  15.62GiB
tinai-embeddings   CPU:  0.00%  MEM:  77.46MiB  /  1GiB
tinai-code         CPU:  0.00%  MEM:  109.6MiB  /  15.62GiB
tinai-comfyui      CPU:  1.64%  MEM:  749.1MiB  /  4GiB
tinai-filebrowser  CPU:  4.03%  MEM:  15.38MiB  /  15.62GiB
tinai-swap         CPU:  0.00%  MEM:  10.64MiB  /  15.62GiB
```

### Notes
- **llama-server** télécharge Qwen2.5-Coder-3B (~3 GB) au 1er démarrage
- **Vision** utilise LLaVA-Phi-3-mini (1 seul fichier GGUF, pas de mmproj séparé)
- **OpenFang** buildé depuis source (image cachée entre les runs)
- **Qdrant** remplace LanceDB (pas d'image Docker standalone disponible)
