# TinAI – Test Report

**Date   :** 2026-03-10 16:05 UTC
**Run    :** [#46](https://github.com/MX10-AC2N/TinAI/actions/runs/22911757191)
**Commit :** `7c531e3956d7da116737f99c96e743fa5a1bd1cc`
**Branch :** `main`

---

**Date    :** 2026-03-10 16:04 UTC
**Run     :** [#46](https://github.com/MX10-AC2N/TinAI/actions/runs/22911757191)
**Commit  :** `7c531e3956d7da116737f99c96e743fa5a1bd1cc`
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
[llama] Fallback wget...
[llama] ✗ wget échoué
[llama] Fallback curl...
[llama] ✗ curl échoué
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-10T16:04:01.423126Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-10T16:04:01.423150Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-10T16:04:01.423596Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m OpenFang API server listening on http://0.0.0.0:4200
[2m2026-03-10T16:04:01.423609Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebChat UI available at http://0.0.0.0:4200/
[2m2026-03-10T16:04:01.423614Z[0m [32m INFO[0m [2mopenfang_api::server[0m[2m:[0m WebSocket endpoint: ws://0.0.0.0:4200/api/agents/{id}/ws
[2m2026-03-10T16:04:05.104368Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mbff9a99f-3522-48f3-a3e9-dfaf2a08a691 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-10T16:04:15.153455Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mc6015aba-dbd4-4869-801c-1b71a6dfc660 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:04:25.198875Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0mf1a77951-7334-4310-9377-9458e0babb7f [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:04:35.244965Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m8f973544-195f-4f06-906b-1e5cff45b0b4 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:04:35.716040Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m1d5c15ca-f133-4224-868c-90e210e821df [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-10 16:04:33.230 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-10 16:04:33.230 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-10 16:04:33.242 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-10 16:04:35.670 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:41268 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:04:35.679 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:41278 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:04:35.709 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:41292 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:04:35.809 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:51554 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
**Date    :** 2026-03-10 16:05 UTC
**Run     :** [#46](https://github.com/MX10-AC2N/TinAI/actions/runs/22911757191)
**Commit  :** `7c531e3956d7da116737f99c96e743fa5a1bd1cc`
**Branch  :** `main`
**Arch    :** `arm64` (`linux/arm64`)
**tinai   :** `tinai:v4-arm64` — 208MB
**webui   :** `tinai-webui:v4-arm64` — 2.56GB

---

## État des conteneurs

```
NAME          IMAGE                  COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64         "/usr/bin/supervisor…"   tinai     46 seconds ago   Up 46 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   tinai-webui:v4-arm64   "open-webui serve --…"   webui     40 seconds ago   Up 40 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```

## Services supervisord (tinai)

```
llama                            FATAL     Exited too quickly (process log may have details)
openfang                         RUNNING   pid 8, uptime 0:00:44
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
[llama] Fallback wget...
[llama] ✗ wget échoué
[llama] Fallback curl...
[llama] ✗ curl échoué
[llama] ✗ FATAL : impossible de télécharger le modèle.
[llama]   → Monte ton fichier .gguf dans /data/models/ et relance.
[llama]   → Exemple : docker cp ./mon-modele.gguf tinai:/data/models/qwen3-1.7b-q4_k_m.gguf
```

## Logs OpenFang

```
[2m2026-03-10T16:04:49.566704Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mvllm [3merror[0m[2m=[0m"error sending request for url (http://localhost:8000/v1/models)"
[2m2026-03-10T16:04:49.567036Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlmstudio [3merror[0m[2m=[0m"error sending request for url (http://localhost:1234/v1/models)"
[2m2026-03-10T16:04:49.567300Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mlemonade [3merror[0m[2m=[0m"error sending request for url (http://localhost:8888/api/v1/models)"
[2m2026-03-10T16:04:49.567325Z[0m [33m WARN[0m [2mopenfang_kernel::kernel[0m[2m:[0m Local provider offline [3mprovider[0m[2m=[0mclaude-code [3merror[0m[2m=[0m"builder error"
[2m2026-03-10T16:04:52.851684Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m8dff83e7-8a7a-4343-9171-d93994965c23 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m1
[2m2026-03-10T16:05:02.886536Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m9f9254e6-79f3-4578-a9bb-be2d519ecf9d [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:05:12.918417Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m85a012e1-fb5d-4381-97ab-b7930682ed10 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:05:22.950698Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m8c3d9b9c-ff02-47f7-a1b1-4c6c8bb27a89 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:05:32.979993Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m6d308b8c-63de-4d3d-b66a-6aa27b0d14e9 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/api/health [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
[2m2026-03-10T16:05:33.559155Z[0m [32m INFO[0m [2mopenfang_api::middleware[0m[2m:[0m API request [3mrequest_id[0m[2m=[0m7b16d7a9-7649-464b-b7ea-b83d4a7d2604 [3mmethod[0m[2m=[0mGET [3mpath[0m[2m=[0m/ [3mstatus[0m[2m=[0m200 [3mlatency_ms[0m[2m=[0m0
```

## Logs Open WebUI

```
tinai-webui  | - UNEXPECTED[3m	:can be ignored when loading from different task/architecture; not ok if you expect identical arch.[0m
tinai-webui  | INFO:     Started server process [1]
tinai-webui  | INFO:     Waiting for application startup.
tinai-webui  | 2026-03-10 16:05:30.041 | INFO     | open_webui.utils.logger:start_logger:198 - GLOBAL_LOG_LEVEL: INFO
tinai-webui  | 2026-03-10 16:05:30.041 | INFO     | open_webui.main:lifespan:627 - Installing external dependencies of functions and tools...
tinai-webui  | 2026-03-10 16:05:30.053 | INFO     | open_webui.utils.plugin:install_frontmatter_requirements:434 - No requirements found in frontmatter.
tinai-webui  | 2026-03-10 16:05:33.521 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:44550 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:05:33.529 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:44556 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:05:33.553 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 172.18.0.1:44570 - "GET / HTTP/1.1" 200
tinai-webui  | 2026-03-10 16:05:33.725 | INFO     | uvicorn.protocols.http.httptools_impl:send:483 - 127.0.0.1:58636 - "GET / HTTP/1.1" 200
```

---

## Notes
- llama-server : modèle non téléchargé en CI (normal)
- Open WebUI   : conteneur dédié, démarre sans attendre llama
- OpenFang     : daemon Rust démarré
---

*Rapports détaillés disponibles en artifacts du workflow.*
