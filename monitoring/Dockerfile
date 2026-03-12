FROM python:3.12-slim

# Nginx + docker CLI (pour docker logs)
RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx docker.io \
    && rm -rf /var/lib/apt/lists/*

# Dashboard
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/sites-enabled/default

# API
COPY api.py /app/api.py

# Script de démarrage (nginx + api.py en parallèle)
RUN printf '#!/bin/sh\nnginx\npython3 /app/api.py\n' > /start.sh && chmod +x /start.sh

EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s \
    CMD python3 -c "import urllib.request; urllib.request.urlopen(\"http://localhost:8888/health\")"

CMD ["/start.sh"]
