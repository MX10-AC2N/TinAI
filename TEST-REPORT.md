# TinAI – Test Report

**Date   :** 2026-03-11 14:22 UTC
**Run    :** [#65](https://github.com/MX10-AC2N/TinAI/actions/runs/22957169342)
**Commit :** `cc2e4f4a1503430ff5e8b73eda8700d7778504a3`
**Branch :** `main`

---

## amd64

## État des conteneurs

```
NAME          IMAGE                                     COMMAND                  SERVICE   CREATED          STATUS                             PORTS
tinai         tinai:v4-amd64                            "/usr/bin/supervisor…"   tinai     31 seconds ago   Up 31 seconds (healthy)            0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   ghcr.io/open-webui/open-webui:main-slim   "bash start.sh"          webui     26 seconds ago   Up 25 seconds (health: starting)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```


## arm64

## État des conteneurs

```
NAME          IMAGE                                     COMMAND                  SERVICE   CREATED          STATUS                    PORTS
tinai         tinai:v4-arm64                            "/usr/bin/supervisor…"   tinai     37 seconds ago   Up 36 seconds (healthy)   0.0.0.0:4200->4200/tcp, [::]:4200->4200/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp
tinai-webui   ghcr.io/open-webui/open-webui:main-slim   "bash start.sh"          webui     31 seconds ago   Up 30 seconds (healthy)   0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp
```


---

*Rapports détaillés disponibles en artifacts du workflow.*
