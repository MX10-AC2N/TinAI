# TinAI – Test Report

**Date   :** 2026-03-10 19:09 UTC
**Run    :** [#47](https://github.com/MX10-AC2N/TinAI/actions/runs/22919609713)
**Commit :** `e24e567e64390b4affee94bca5a1b9d4dfb61f27`
**Branch :** `main`

---

**Date    :** 2026-03-10 19:09 UTC
**Run     :** [#47](https://github.com/MX10-AC2N/TinAI/actions/runs/22919609713)
**Commit  :** `e24e567e64390b4affee94bca5a1b9d4dfb61f27`
**Branch  :** `main`
**Arch    :** `amd64` (`linux/amd64`)
**tinai   :** `tinai:v4-amd64` — 193MB
**webui   :** `tinai-webui:v4-amd64` — 2.88GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-amd64         "/usr/bin/supervisor…"   tinai     36 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-amd64   "open-webui serve --…"   webui     31 seconds ago   Up 30 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:35
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
[2m2026-03-10T19:08:39.726226Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-10T19:08:39.726251Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-10T19:08:39.726588Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-10T19:08:39.726598Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-10T19:08:39.726601Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-10T19:08:43.335934Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mb8cb1fb2-60fb-419e-9582-ed34bf2a8c5e [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-10T19:08:53.384603Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m01503931-063a-4404-b343-6a836c8f88ce [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:03.440752Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m1c233f6d-d284-4645-9020-00301a4c107a [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:13.488821Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mc71f495c-14b9-4b98-b701-3e82bf6c68d7 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:13.960598Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0me721ab45-12e1-455c-8a04-683341ad4b5f [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-10 19:09:13.412 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-10 19:09:13.412 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-10 19:09:13.427 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-10 19:09:13.915 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50590 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:13.924 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50594 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:13.953 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:50600 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:14.083 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:60304 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-10 19:09 UTC
**Run     :** [#47](https://github.com/MX10-AC2N/TinAI/actions/runs/22919609713)
**Commit  :** `e24e567e64390b4affee94bca5a1b9d4dfb61f27`
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
[2m2026-03-10T19:08:54.954704Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-10T19:08:54.954733Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-10T19:08:54.954857Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-10T19:08:54.954874Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-10T19:08:54.954877Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-10T19:08:58.556970Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m0a7c885a-181e-4e6c-9bc2-7a596af3b1e5 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:08.587850Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m7aa07e09-de81-48dc-8469-47479566b5f6 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:18.615256Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9d0d4042-b8ff-4c31-a962-728038c5b19e [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:28.646307Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m3ca999a7-6068-426c-95c2-52bd059c4c84 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T19:09:34.199549Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m99e6791b-ac6f-4281-a445-63f496c6172b [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-10 19:09:30.991 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-10 19:09:30.991 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-10 19:09:31.002 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-10 19:09:34.164 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:54958 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:34.171 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:54972 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:34.193 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:54976 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 19:09:34.223 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:44688 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
