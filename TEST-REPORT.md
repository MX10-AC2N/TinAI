# TinAI – Test Report

**Date   :** 2026-03-11 06:39 UTC
**Run    :** [#53](https://github.com/MX10-AC2N/TinAI/actions/runs/22939987664)
**Commit :** `7a241407242c1aef2f7814e086dd4923d5db93e1`
**Branch :** `main`

---

**Date    :** 2026-03-11 06:39 UTC
**Run     :** [#53](https://github.com/MX10-AC2N/TinAI/actions/runs/22939987664)
**Commit  :** `7a241407242c1aef2f7814e086dd4923d5db93e1`
**Branch  :** `main`
**Arch    :** `amd64` (`linux/amd64`)
**tinai   :** `tinai:v4-amd64` — 193MB
**webui   :** `tinai-webui:v4-amd64` — 2.88GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-amd64         "/usr/bin/supervisor…"   tinai     37 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-amd64   "open-webui serve --…"   webui     31 seconds ago   Up 30 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:34
N/A
```

## Logs llama-server

```
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : AVX2+FMA (Haswell+, Ryzen — très bonnes performances)
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : AVX2+FMA (Haswell+, Ryzen — très bonnes performances)
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
[2m2026-03-11T06:38:25.446582Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:38:25.446607Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:38:25.446952Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T06:38:25.446962Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:38:25.446965Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:38:29.058697Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mcd2512ca-c687-49a8-b6ef-6bbd109a7f3e [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-11T06:38:39.104541Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m13d18f37-8389-41cb-bac0-797edb565982 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:49.148996Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m1e9392af-4d2a-4812-a580-82e15bc1526f [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:59.196293Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m73bdde60-c9bc-414a-80d1-2e8e2a1f7406 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:59.626851Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9c264e7a-828d-4f52-bb37-14e8b2488a28 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:38:58.823 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:38:58.823 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:38:58.835 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:38:59.581 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:37462 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:59.590 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:37474 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:59.620 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:37480 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:59.721 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:41020 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 06:38 UTC
**Run     :** [#53](https://github.com/MX10-AC2N/TinAI/actions/runs/22939987664)
**Commit  :** `7a241407242c1aef2f7814e086dd4923d5db93e1`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     41 seconds ago   Up 41 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
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
[llama] CPU     : NEON+SVE (Graviton3, Neoverse N2 — performances maximales ARM)
[llama] Threads : 2 (cœurs physiques)
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Port    : 8081 | ctx=2048 | gpu_layers=0
[llama] ════════════════════════════════════════
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] ════════════════════════════════════════
[llama] CPU     : NEON+SVE (Graviton3, Neoverse N2 — performances maximales ARM)
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
[2m2026-03-11T06:37:49.913370Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:37:49.913396Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:37:49.913438Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T06:37:49.913454Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:37:49.913457Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:37:53.594497Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0me4a52c72-14ce-4428-ae82-90cdcfb3ea9d [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:03.627351Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m7f7db4d9-c410-4afd-a312-be1f8312e260 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:13.662433Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0md3e44be7-3cd9-4429-8e98-f8462d24fe76 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:23.694006Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mf9903bea-9d8a-47ac-ad37-49ce24f9b317 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:38:29.221431Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m94976805-7fbc-406c-821d-db07754256ae [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:38:25.357 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:38:25.358 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:38:25.368 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:38:29.185 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50690 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:29.193 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50702 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:29.215 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50704 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:38:29.261 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:35160 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
