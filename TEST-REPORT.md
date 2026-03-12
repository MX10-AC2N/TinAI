# TinAI – Test Report

**Date   :** 2026-03-12 11:37 UTC
**Run    :** [#90](https://github.com/MX10-AC2N/TinAI/actions/runs/22999987046)
**Commit :** `1bf2f4a56a06e9243b69ce5a997ff1f49352286d`
**Branch :** `main`

---

## amd64

## État des conteneurs

```
NAME          IMAGE                               COMMAND                  SERVICE   CREATED         STATUS                            PORTS
tinai         tinai:v5-amd64                      "/usr/local/bin/star…"   tinai     6 seconds ago   Up 5 seconds (healthy)            0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-llama   ghcr.io/ggml-org/llama.cpp:server   "sh /llama-entrypoin…"   llama     6 seconds ago   Up 5 seconds (health: starting)   0.0.0.0:8081->8080/tcp, [::]:8081->8080/tcp
```


## arm64

## État des conteneurs

```
NAME          IMAGE                               COMMAND                  SERVICE   CREATED         STATUS                          PORTS
tinai         tinai:v5-arm64                      "/usr/local/bin/star…"   tinai     6 seconds ago   Up 5 seconds (healthy)          0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-llama   ghcr.io/ggml-org/llama.cpp:server   "sh /llama-entrypoin…"   llama     6 seconds ago   Restarting (255) 1 second ago   
```


---

*Rapports détaillés disponibles en artifacts du workflow.*
