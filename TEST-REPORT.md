# TinAI – Test Report

**Date   :** 2026-03-11 08:29 UTC
**Run    :** [#63](https://github.com/MX10-AC2N/TinAI/actions/runs/22943463523)
**Commit :** `4c5eba5c1565ff67c191f8913b02cc7a203fe699`
**Branch :** `main`

---

## amd64

## État des conteneurs

```
NAME          IMAGE                                     COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-amd64                            "/usr/bin/supervisor…"   tinai     32 seconds ago   Up 32 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   ghcr.io/open-webui/open-webui:main-slim   "bash start.sh"          webui     27 seconds ago   Up 26 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```


## arm64

## État des conteneurs

```
NAME          IMAGE                                     COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64                            "/usr/bin/supervisor…"   tinai     36 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   ghcr.io/open-webui/open-webui:main-slim   "bash start.sh"          webui     31 seconds ago   Up 30 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```


---

*Rapports détaillés disponibles en artifacts du workflow.*
