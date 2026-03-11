# TinAI – Test Report

**Date   :** 2026-03-11 06:35 UTC
**Run    :** [#52](https://github.com/MX10-AC2N/TinAI/actions/runs/22939971194)
**Commit :** `4078aba67e03c32e9f35e6861c293aac5d288a58`
**Branch :** `main`

---

**Date    :** 2026-03-11 06:34 UTC
**Run     :** [#52](https://github.com/MX10-AC2N/TinAI/actions/runs/22939971194)
**Commit  :** `4078aba67e03c32e9f35e6861c293aac5d288a58`
**Branch  :** `main`
**Arch    :** `amd64` (`linux/amd64`)
**tinai   :** `tinai:v4-amd64` — 192MB
**webui   :** `tinai-webui:v4-amd64` — 2.88GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-amd64         "/usr/bin/supervisor…"   tinai     36 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-amd64   "open-webui serve --…"   webui     31 seconds ago   Up 31 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:35
N/A
```

## Logs llama-server

```
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : inconnu
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : inconnu
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-11T06:33:57.633953Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:33:57.633972Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:33:57.635411Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T06:33:57.635424Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:33:57.635429Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:34:01.308003Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m832ff4d6-3eb0-4fb0-81ac-b9e109022a5c [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-11T06:34:11.363226Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m77de0bd4-8d35-4cf5-b3dd-a6900a2e0c5a [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:21.409090Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m702e9e32-2c2b-434d-a566-3ce7a61bfccc [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:31.455659Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m440b5262-09fc-46b2-8d66-1e6d98b28996 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:31.925741Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9c26bb91-665f-4004-9627-23db6ffd7c1f [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:34:30.252 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:34:30.253 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:34:30.264 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:34:31.870 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36822 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:31.880 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36836 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:31.918 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36842 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:32.056 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:47196 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 06:34 UTC
**Run     :** [#52](https://github.com/MX10-AC2N/TinAI/actions/runs/22939971194)
**Commit  :** `4078aba67e03c32e9f35e6861c293aac5d288a58`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     42 seconds ago   Up 41 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-arm64   "open-webui serve --…"   webui     36 seconds ago   Up 35 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:40
N/A
```

## Logs llama-server

```
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : inconnu
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : inconnu
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-11T06:33:59.710321Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mollama [3merror[0m[2m=[0m"error sending request for url (http://localhost:11434/api/tags)"
[2m2026-03-11T06:33:59.711003Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mvllm [3merror[0m[2m=[0m"error sending request for url (http://localhost:8000/v1/models)"
[2m2026-03-11T06:33:59.711296Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlmstudio [3merror[0m[2m=[0m"error sending request for url (http://localhost:1234/v1/models)"
[2m2026-03-11T06:33:59.711605Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:33:59.711632Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:34:03.189671Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m727b550e-9c92-4206-a54f-e55103ee000f [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:13.220824Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m907109ab-43a0-4a07-9650-c7f3b5bc32b8 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:23.254701Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0md83e1fef-7028-4f1f-beea-166ee643d8ba [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:33.295139Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m40c00103-fcfa-4af6-935f-84e7d97de777 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:38.786921Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0me8ea5b42-c8cd-4a81-93a7-d258e86caf7b [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:34:35.736 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:34:35.736 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:34:35.749 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:34:38.748 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:49214 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:38.756 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:49222 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:38.781 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:49232 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:38.812 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:35832 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
