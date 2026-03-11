# TinAI – Test Report

**Date   :** 2026-03-11 05:58 UTC
**Run    :** [#49](https://github.com/MX10-AC2N/TinAI/actions/runs/22938868153)
**Commit :** `affb7c99e11a61dc6f273bdd1f67e36a8590dc59`
**Branch :** `main`

---

**Date    :** 2026-03-11 05:58 UTC
**Run     :** [#49](https://github.com/MX10-AC2N/TinAI/actions/runs/22938868153)
**Commit  :** `affb7c99e11a61dc6f273bdd1f67e36a8590dc59`
**Branch  :** `main`
**Arch    :** `amd64` (`linux/amd64`)
**tinai   :** `tinai:v4-amd64` — 193MB
**webui   :** `tinai-webui:v4-amd64` — 2.88GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                             PORTS
tinai         tinai:v4-amd64         "/usr/bin/supervisor…"   tinai     37 seconds ago   Up 36 seconds (healthy)            0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-amd64   "open-webui serve --…"   webui     31 seconds ago   Up 30 seconds (health: starting)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
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
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
```

## Logs OpenFang

```
[2m2026-03-11T05:57:44.486826Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T05:57:44.486844Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T05:57:44.487201Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T05:57:44.487213Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T05:57:44.487218Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T05:57:48.149303Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mced71088-f351-4abe-8a34-2e4f799e7cca [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-11T05:57:58.195401Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m2cf26ef1-d031-48a8-9b4b-4581acf75924 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:58:08.247941Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mbc7964c0-32d4-437a-8e61-7bbecf9763ba [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:58:18.295928Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mb0020755-3899-4fbe-b35e-d8a518b45ac0 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:58:18.762940Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m7d8ac9e8-7643-4d50-9e2d-b0b3faba6992 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 05:58:16.205 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 05:58:16.205 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 05:58:16.219 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 05:58:18.719 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:53170 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:58:18.728 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:53182 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:58:18.756 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:53196 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:58:19.409 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:52950 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 05:57 UTC
**Run     :** [#49](https://github.com/MX10-AC2N/TinAI/actions/runs/22938868153)
**Commit  :** `affb7c99e11a61dc6f273bdd1f67e36a8590dc59`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                             PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     42 seconds ago   Up 41 seconds (healthy)            0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-arm64   "open-webui serve --…"   webui     36 seconds ago   Up 35 seconds (health: starting)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
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
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
[llama] Modèle absent – téléchargement via llama-server natif...
[llama] Repo : Qwen/Qwen3-1.7B-GGUF  Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Lancement sur :8081 | alias=qwen3-1.7b | threads=2 | ctx=2048
```

## Logs OpenFang

```
[2m2026-03-11T05:57:08.143935Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T05:57:08.143954Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T05:57:08.143957Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T05:57:08.144082Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T05:57:08.144135Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T05:57:11.755660Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m7ea7f2a9-1dee-44f0-a0d7-e51450ad4de6 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:21.800363Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0md776b62e-19d1-445e-8ac6-fb3583387c9d [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:31.834271Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mfb972976-9679-4bc6-a159-58e637849c8c [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:42.884741Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m77cf0dbc-6711-44c4-a6a8-a409f2b84238 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m35
[2m2026-03-11T05:57:47.470469Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9a90e2ce-b7fa-4172-a06e-7354c5310b0d [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
```

## Logs Open WebUI

```
tinai-webui  | [3mNotes:
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 05:57:44.753 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 05:57:44.753 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 05:57:44.767 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 05:57:47.430 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:60188 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:47.439 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:60194 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:47.463 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:60204 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:47.793 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:45714 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
