# TinAI – Test Report

**Date   :** 2026-03-11 06:34 UTC
**Run    :** [#51](https://github.com/MX10-AC2N/TinAI/actions/runs/22939960584)
**Commit :** `0594769fe0a53013dd1cdf0f34fe61bee077fbfc`
**Branch :** `main`

---

**Date    :** 2026-03-11 06:33 UTC
**Run     :** [#51](https://github.com/MX10-AC2N/TinAI/actions/runs/22939960584)
**Commit  :** `0594769fe0a53013dd1cdf0f34fe61bee077fbfc`
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
[2m2026-03-11T06:33:01.611686Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:33:01.611688Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:33:01.611908Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlmstudio [3merror[0m[2m=[0m"error sending request for url (http://localhost:1234/v1/models)"
[2m2026-03-11T06:33:01.612111Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:33:01.612151Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:33:05.311775Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m154bc930-3172-46b6-9980-f0cc9503eb86 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-11T06:33:15.358864Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m8d27e61d-915d-4064-9df5-0cbc744ce415 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:33:25.405860Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m06aab854-f5d4-4bde-91c6-6558737d4af5 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:33:35.452445Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mcddd9814-43b0-4053-9026-380a776c7661 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:33:36.390421Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m8f7d5950-4fa7-4b44-aadb-2574bdbde0a0 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:33:31.772 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:33:31.772 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:33:31.783 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:33:36.353 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:38120 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:33:36.355 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36426 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:33:36.363 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36434 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:33:36.384 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36442 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 06:34 UTC
**Run     :** [#51](https://github.com/MX10-AC2N/TinAI/actions/runs/22939960584)
**Commit  :** `0594769fe0a53013dd1cdf0f34fe61bee077fbfc`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     42 seconds ago   Up 41 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-arm64   "open-webui serve --…"   webui     36 seconds ago   Up 36 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
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
[2m2026-03-11T06:33:33.738343Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T06:33:33.738345Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T06:33:33.738530Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlmstudio [3merror[0m[2m=[0m"error sending request for url (http://localhost:1234/v1/models)"
[2m2026-03-11T06:33:33.738855Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T06:33:33.738894Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T06:33:37.305954Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mcbd251d5-54ab-4abb-8604-85b35a5105dd [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:33:47.336614Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m431706b7-c923-473b-9155-d6cef7ecadae [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:33:57.372638Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m79d62f0a-2a56-4bcc-acce-3664d3ca9fd8 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T06:34:07.425804Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m74e53192-26d0-4da3-a06c-77469db34856 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m4
[2m2026-03-11T06:34:13.536797Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0me2754172-3aec-45e4-b6fc-3d6d342ac216 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 06:34:08.172 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 06:34:08.173 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 06:34:08.186 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 06:34:13.501 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:51896 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:13.504 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:41472 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:13.509 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:51908 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 06:34:13.530 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:51912 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
