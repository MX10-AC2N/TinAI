# TinAI – Test Report

**Date   :** 2026-03-11 16:41 UTC
**Run    :** [#72](https://github.com/MX10-AC2N/TinAI/actions/runs/22963623011)
**Commit :** `03d236ea72068bf01f2fa8c671d9d76c4d2d6648`
**Branch :** `main`

---

## amd64

## État des conteneurs

```
NAME          IMAGE                               COMMAND                  SERVICE   CREATED         STATUS                                  PORTS
tinai         tinai:v5-amd64                      "/usr/local/bin/star…"   tinai     6 seconds ago   Up 5 seconds (healthy)                  0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-llama   ghcr.io/ggml-org/llama.cpp:server   "/app/llama-server -…"   llama     6 seconds ago   Restarting (1) Less than a second ago   
```


## arm64

## État des conteneurs

```
NAME          IMAGE                               COMMAND                  SERVICE   CREATED         STATUS                          PORTS
tinai         tinai:v5-arm64                      "/usr/local/bin/star…"   tinai     6 seconds ago   Up 5 seconds (healthy)          0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp
tinai-llama   ghcr.io/ggml-org/llama.cpp:server   "/app/llama-server -…"   llama     6 seconds ago   Restarting (255) 1 second ago   
```


---

*Rapports détaillés disponibles en artifacts du workflow.*
