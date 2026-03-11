# TinAI – Test Report

**Date   :** 2026-03-11 05:58 UTC
**Run    :** [#48](https://github.com/MX10-AC2N/TinAI/actions/runs/22938846853)
**Commit :** `0cf4f7f3ac25cf192ca15cb4ab74836c4c7415f4`
**Branch :** `main`

---

**Date    :** 2026-03-11 05:57 UTC
**Run     :** [#48](https://github.com/MX10-AC2N/TinAI/actions/runs/22938846853)
**Commit  :** `0cf4f7f3ac25cf192ca15cb4ab74836c4c7415f4`
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
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Démarrage llama-server...
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Modèle absent – téléchargement depuis HuggingFace...
[llama] Repo    : Qwen/Qwen3-1.7B-GGUF
[llama] Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Tentative via huggingface_hub (Python)...
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'huggingface_hub'
[llama] Tentative curl...
[llama] ✗ curl échoué
[llama] Tentative wget...
[llama] ✗ wget échoué
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-11T05:56:57.358668Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T05:56:57.358694Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T05:56:57.359131Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T05:56:57.359144Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T05:56:57.359149Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T05:57:01.026071Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m6abb02f1-52df-4050-86ef-746b682f4998 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-11T05:57:11.080427Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mefa4b51f-21f2-4731-b884-93a0e8a6a345 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:21.131700Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0maecb017d-22b0-4155-8d3e-2bc2594954c7 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:31.179055Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m85bdf453-4f10-467c-98f5-12886b47fa28 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:31.654322Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mf21d2f86-0156-4bae-93bc-58e3f279a8da [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 05:57:30.920 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 05:57:30.920 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 05:57:30.932 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 05:57:31.606 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:48062 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:31.616 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:48068 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:31.647 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:48078 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:31.783 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:45190 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-11 05:57 UTC
**Run     :** [#48](https://github.com/MX10-AC2N/TinAI/actions/runs/22938846853)
**Commit  :** `0cf4f7f3ac25cf192ca15cb4ab74836c4c7415f4`
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
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Démarrage llama-server...
[llama] Modèle  : /data/models/qwen3-1.7b-q4_k_m.gguf
[llama] Alias   : qwen3-1.7b
[llama] Modèle absent – téléchargement depuis HuggingFace...
[llama] Repo    : Qwen/Qwen3-1.7B-GGUF
[llama] Fichier : qwen3-1.7b-q4_k_m.gguf
[llama] Tentative via huggingface_hub (Python)...
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'huggingface_hub'
[llama] Tentative curl...
[llama] ✗ curl échoué
[llama] Tentative wget...
[llama] ✗ wget échoué
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-11T05:56:31.286022Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-11T05:56:31.286054Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-11T05:56:31.286247Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-11T05:56:31.286267Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-11T05:56:31.286271Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-11T05:56:34.912202Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9dd3db7a-b918-415e-9c24-6aed32358c4d [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:56:44.945884Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m801222c7-9d9d-4772-bd4e-970a4c397ef3 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:56:54.976489Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mdccb17b7-dfb0-4b59-8613-862adc2511ed [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-11T05:57:06.474869Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m234426bc-76db-40aa-8bd3-fdfa021f278a [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m5
[2m2026-03-11T05:57:10.584001Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m55c31238-9e23-48da-9828-1f7e5fa79705 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | [3mNotes:
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-11 05:57:08.495 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-11 05:57:08.496 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-11 05:57:08.509 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-11 05:57:10.546 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36182 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:10.554 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36196 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-11 05:57:10.577 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:36204 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
