# TinAI – Test Report

**Date   :** 2026-03-11 06:50 UTC
**Run    :** [#54](https://github.com/MX10-AC2N/TinAI/actions/runs/22940399535)
**Commit :** `ec98859512bd719c5d595abb7fc6f1543e876cac`
**Branch :** `main`

---

**Date    :** 2026-03-11 06:49 UTC
**Run     :** [#54](https://github.com/MX10-AC2N/TinAI/actions/runs/22940399535)
**Commit  :** `ec98859512bd719c5d595abb7fc6f1543e876cac`
**Branch  :** `main`
**Arch    :** `amd64` (`linux/amd64`)
**tinai   :** `tinai:v4-amd64` — 193MB
**webui   :** `tinai-webui:v4-amd64` — 2.88GB

> Rapport non disponible pour amd64

## arm64

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-amd64         "/usr/bin/supervisor…"   tinai     37 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-amd64   "open-webui serve --…"   webui     32 seconds ago   Up 31 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:36
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
[2m2026-03-11T06:49:04.939012Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:49:04.939038Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:49:04.940890Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T06:49:04.940905Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:49:04.940910Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:49:08.663813Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m56214795-38f7-4d23-b2df-dbc27c6b97eb [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:18.712466Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m148bfcbc-cc06-4645-8ab7-9de421e807ad [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:28.769529Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0me293fa8c-2e31-4889-ab8a-26fdea306631 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:38.823315Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m1681efe3-4fc7-4038-a69b-a61fe7b622a9 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:39.881697Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m97824d22-4a5a-4ff7-b4b1-81831aaa578b [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:49:37.441 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:49:37.441 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:49:37.451 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:49:39.822 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:36358 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:49:39.824 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52168 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:49:39.835 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52170 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:49:39.874 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52180 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 06:50 UTC
**Run     :** [#54](https://github.com/MX10-AC2N/TinAI/actions/runs/22940399535)
**Commit  :** `ec98859512bd719c5d595abb7fc6f1543e876cac`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     41 seconds ago   Up 41 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-arm64   "open-webui serve --…"   webui     35 seconds ago   Up 35 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
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
[2m2026-03-11T06:49:28.252442Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:49:28.252473Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:49:28.252691Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T06:49:28.252708Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:49:28.252710Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:49:31.881003Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0md19dc203-626a-42cc-a16b-2451c938d25c [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:41.913485Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m4399351e-1421-4ca2-9f37-855cb0dd5d44 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:49:51.940731Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m3fa03f26-a92e-488e-9148-0aac9b1868c1 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:50:01.999085Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m3c389a78-c46b-4224-a954-5b93c09d9652 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m3
[2m2026-03-11T06:50:07.460780Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mfddd70f5-e11f-4885-8caf-9e6169a111d7 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:50:03.551 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:50:03.551 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:50:03.564 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:50:07.427 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52262 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:50:07.434 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52266 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:50:07.455 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:52272 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:50:07.560 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:46596 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
