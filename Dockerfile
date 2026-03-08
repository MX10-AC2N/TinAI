# ══════════════════════════════════════════════════════════════════
#  TinAI v3 – Image unique multi-architecture
#  Cibles : linux/amd64 · linux/arm64
#  Contenu : llama.cpp (server) + Open WebUI + OpenFang
#  Modèle  : Qwen3-1.7B (GGUF, CPU-only, téléchargé au 1er run)
# ══════════════════════════════════════════════════════════════════

# ── ARG globaux (avant tout FROM) ────────────────────────────────
ARG TARGETARCH
ARG TARGETPLATFORM

# ══════════════════════════════════════════════════════════════════
#  Étape 1 : Build llama.cpp
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim AS llama-builder

ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake make g++ libssl-dev curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/ggml-org/llama.cpp /src
WORKDIR /src

# Flags adaptés à l'architecture cible
RUN set -eux; \
    CMAKE_EXTRA=""; \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        CMAKE_EXTRA="-DGGML_NEON=ON"; \
    fi; \
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DGGML_NATIVE=OFF \
        -DLLAMA_BUILD_SERVER=ON \
        -DBUILD_SHARED_LIBS=OFF \
        ${CMAKE_EXTRA} \
    && cmake --build build --config Release -j$(nproc) --target llama-server

# ══════════════════════════════════════════════════════════════════
#  Étape 2 : Image finale
# ══════════════════════════════════════════════════════════════════
FROM python:3.11-slim-bookworm

ARG TARGETARCH
ARG TARGETPLATFORM

LABEL org.opencontainers.image.title="TinAI v3"
LABEL org.opencontainers.image.description="llama.cpp + Open WebUI + OpenFang – image unique multi-arch"
LABEL org.opencontainers.image.source="https://github.com/MX10-AC2N/TinAI"
LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"

# Dépendances runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 \
    supervisor procps wget \
    && rm -rf /var/lib/apt/lists/*

# ── llama.cpp server ──────────────────────────────────────────────
COPY --from=llama-builder /src/build/bin/llama-server /usr/local/bin/llama-server

# ── Open WebUI (package PyPI – supporte nativement amd64 + arm64) ─
RUN pip install --no-cache-dir \
    open-webui \
    huggingface_hub \
    && pip cache purge

# ── OpenFang ──────────────────────────────────────────────────────
RUN pip install --no-cache-dir openfang 2>/dev/null \
    || pip install --no-cache-dir \
        git+https://github.com/openfang/openfang.git 2>/dev/null \
    || echo "openfang-unavailable"

# ── Répertoires de données ────────────────────────────────────────
RUN mkdir -p \
    /data/models \
    /data/webui \
    /data/openfang \
    /var/log/tinai

# ── Scripts & config ──────────────────────────────────────────────
COPY scripts/start-llama.sh    /usr/local/bin/start-llama.sh
COPY scripts/start-webui.sh    /usr/local/bin/start-webui.sh
COPY scripts/start-openfang.sh /usr/local/bin/start-openfang.sh
COPY scripts/healthcheck.sh    /usr/local/bin/healthcheck.sh
COPY supervisord.conf          /etc/supervisor/conf.d/tinai.conf

RUN chmod +x \
    /usr/local/bin/start-llama.sh \
    /usr/local/bin/start-webui.sh \
    /usr/local/bin/start-openfang.sh \
    /usr/local/bin/healthcheck.sh

# ── Variables d'environnement par défaut ──────────────────────────
ENV LLAMA_MODEL_PATH=/data/models/qwen3-1.7b.gguf \
    LLAMA_HF_REPO=Qwen/Qwen3-1.7B-GGUF \
    LLAMA_HF_FILE=qwen3-1.7b-q5_k_m.gguf \
    LLAMA_CTX_SIZE=8192 \
    LLAMA_THREADS=4 \
    LLAMA_GPU_LAYERS=0 \
    LLAMA_PORT=8081 \
    WEBUI_PORT=3000 \
    WEBUI_SECRET_KEY=tinai-secret-change-me \
    OPENFANG_PORT=4200 \
    TINAI_API_KEY=sk-tinai \
    DATA_DIR=/data

VOLUME ["/data/models", "/data/webui", "/data/openfang"]

EXPOSE 3000 4200 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/tinai.conf"]
