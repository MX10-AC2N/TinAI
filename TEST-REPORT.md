## 🧪 TinAI v2 – Test Report

**Date :** 2026-03-04 05:58 UTC
**Run :** [#17](https://github.com/MX10-AC2N/TinAI/actions/runs/22656741656)
**Commit :** `74c5984592a76fc44e079404f0b320ed2524819f`
**Branch :** `main`

### Résultats

| Service | Statut | Endpoint |
|---------|--------|----------|
| Open-WebUI (3000) | ✅ OK | `http://127.0.0.1:3000/` |
| SillyTavern (8008) | ❌ FAIL | `http://127.0.0.1:8008/` |
| Code-Server (8080) | ✅ OK | `http://127.0.0.1:8080/` |
| Embeddings (8084) | ✅ OK | `http://127.0.0.1:8084/health` |
| Qdrant (6333) | ✅ OK | `http://127.0.0.1:6333/healthz` |
| Vision (8085) | ✅ OK | `http://127.0.0.1:8085/health` |
| llama-swap (11434) | ✅ OK | `http://127.0.0.1:11434/health` |
| Caddy (80) | ✅ OK | `http://127.0.0.1:80/` |
| Filebrowser (8083) | ✅ OK | `http://127.0.0.1:8083/` |
| OpenFang (4200) | ❌ FAIL | `http://127.0.0.1:4200/` |
| ComfyUI (7860) | ✅ OK | `http://127.0.0.1:7860/system_stats` |
| llama-server (8081) | ✅ Conteneur actif | modèle en dl au 1er run |
| Aider | ✅ Conteneur actif | CLI uniquement |
| CLI `tinai status` | ✅ OK | - |

### État des conteneurs

```
NAME                IMAGE                                    COMMAND                  SERVICE        CREATED         STATUS                          PORTS
tinai-aider         paulgauthier/aider:latest                "/bin/sh -c 'tail -f…"   aider          5 minutes ago   Up 4 minutes                    
tinai-caddy         caddy:alpine                             "caddy run --config …"   caddy          5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp, 443/udp, 2019/tcp
tinai-code          ghcr.io/coder/code-server:latest         "/usr/bin/entrypoint…"   code-server    5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
tinai-comfyui       yanwk/comfyui-boot:cpu                   "bash /runner-script…"   comfyui        5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:7860->8188/tcp, [::]:7860->8188/tcp
tinai-embeddings    ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   embeddings     5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:8084->8084/tcp, [::]:8084->8084/tcp
tinai-filebrowser   filebrowser/filebrowser:latest           "tini -- /init.sh"       filebrowser    5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:8083->80/tcp, [::]:8083->80/tcp
tinai-llama         ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   llama-server   5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-openfang      tinai-openfang:latest                    "openfang start"         openfang       5 minutes ago   Up 4 minutes (unhealthy)        0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-qdrant        qdrant/qdrant:latest                     "./entrypoint.sh"        qdrant         5 minutes ago   Up 5 minutes (unhealthy)        0.0.0.0:6333-6334->6333-6334/tcp, [::]:6333-6334->6333-6334/tcp
tinai-sillytavern   ghcr.io/sillytavern/sillytavern:latest   "tini -- ./docker-en…"   sillytavern    5 minutes ago   Restarting (1) 24 seconds ago   
tinai-swap          ghcr.io/mostlygeek/llama-swap:cpu        "/app/llama-swap -co…"   llama-swap     5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:11434->8080/tcp, [::]:11434->8080/tcp
tinai-vision        ghcr.io/ggml-org/llama.cpp:server        "/app/llama-server -…"   vision         5 minutes ago   Up 5 minutes (healthy)          0.0.0.0:8085->8085/tcp, [::]:8085->8085/tcp
tinai-webui         ghcr.io/open-webui/open-webui:main       "bash start.sh"          open-webui     5 minutes ago   Up 4 minutes (healthy)          0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
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
  [1;33m⏳[0m OpenFang       → démarrage en cours (port 4200)
  [0;31m❌[0m SillyTavern    → restarting
  [0;32m✅[0m Filebrowser    → [0;36mhttp://localhost:8083[0m
  [0;32m✅[0m ComfyUI        → [0;36mhttp://localhost:7860[0m
  [0;32m✅[0m Qdrant RAG     → [0;36mhttp://localhost:6333[0m
  [0;32m✅[0m Aider          → actif
  [0;32m✅[0m Vision VL      → [0;36mhttp://localhost:8085[0m

[1m💾 Ressources :[0m
tinai-webui        CPU:  0.11%  MEM:  1.126GiB  /  15.62GiB
tinai-aider        CPU:  0.00%  MEM:  1.785MiB  /  15.62GiB
tinai-openfang     CPU:  0.00%  MEM:  4.602MiB  /  15.62GiB
tinai-code         CPU:  0.00%  MEM:  100.2MiB  /  15.62GiB
tinai-llama        CPU:  2.64%  MEM:  1.969GiB  /  5.5GiB
tinai-comfyui      CPU:  0.05%  MEM:  1.255GiB  /  4GiB
tinai-filebrowser  CPU:  0.00%  MEM:  15.05MiB  /  15.62GiB
tinai-caddy        CPU:  0.00%  MEM:  14.07MiB  /  15.62GiB
tinai-vision       CPU:  0.00%  MEM:  1.696GiB  /  4GiB
tinai-qdrant       CPU:  0.03%  MEM:  122.8MiB  /  15.62GiB
tinai-sillytavern  CPU:  0.00%  MEM:  0B        /  0B
tinai-swap         CPU:  0.00%  MEM:  10.67MiB  /  15.62GiB
tinai-embeddings   CPU:  0.00%  MEM:  89.47MiB  /  1GiB
```

### Notes
- **llama-server** télécharge Qwen2.5-Coder-3B (~3 GB) au 1er démarrage
- **Vision** utilise LLaVA-Phi-3-mini (1 seul fichier GGUF, pas de mmproj séparé)
- **OpenFang** buildé depuis source (image cachée entre les runs) — restart: on-failure
- **Aider** daemon maintenu par `tail -f /dev/null` — restart: on-failure
- **ComfyUI** utilise  (image officielle légère), port 8188, endpoint 
- **Qdrant** healthcheck sur `/healthz` (pas `/health`)
- **Ports configurables** via `.env` (copié depuis `.env.example`)
