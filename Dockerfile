# ══════════════════════════════════════════════════════════════════
#  TinAI v3 – Image unique multi-architecture
#  Cibles : linux/amd64 · linux/arm64
#  Contenu : llama.cpp + Open WebUI + OpenFang (Rust binary)
#  Modèle  : configurable via LLAMA_HF_* (téléchargé au 1er run)
# ══════════════════════════════════════════════════════════════════
ARG TARGETARCH
ARG TARGETPLATFORM

# ══════════════════════════════════════════════════════════════════
#  Étape 1 : Build llama.cpp (optimisé AVX2/NEON selon arch)
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim AS llama-builder

ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake make g++ libssl-dev curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/ggml-org/llama.cpp /src
WORKDIR /src

RUN set -eux; \
    CMAKE_EXTRA=""; \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        # NEON SIMD pour ARM64 (Raspberry Pi 4/5, Apple Silicon)
        CMAKE_EXTRA="-DGGML_NEON=ON"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
        # AVX2 désactivé volontairement (GGML_NATIVE=OFF) pour compatibilité max
        # Active -DGGML_AVX2=ON si tu cibles uniquement des CPU récents (>2013)
        CMAKE_EXTRA="-DGGML_AVX=ON"; \
    fi; \
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DGGML_NATIVE=OFF \
        -DLLAMA_BUILD_SERVER=ON \
        -DBUILD_SHARED_LIBS=OFF \
        ${CMAKE_EXTRA} \
    && cmake --build build --config Release -j$(nproc) --target llama-server \
    && strip build/bin/llama-server

# ══════════════════════════════════════════════════════════════════
#  Étape 2 : Build OpenFang (binaire Rust statique)
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim AS openfang-builder

ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential ca-certificates \
    libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Installer Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile minimal
ENV PATH="/root/.cargo/bin:$PATH"

# Cloner et compiler OpenFang (sans le crate desktop Tauri)
RUN git clone --depth=1 https://github.com/RightNow-AI/openfang /src
WORKDIR /src

RUN set -eux; \
    cargo build --release \
        --workspace \
        --exclude openfang-desktop \
        -p openfang-cli \
    && cp target/release/openfang /openfang-bin \
    && strip /openfang-bin

# ══════════════════════════════════════════════════════════════════
#  Étape 3 : Image finale
# ══════════════════════════════════════════════════════════════════
FROM python:3.11-slim-bookworm

ARG TARGETARCH
ARG TARGETPLATFORM

LABEL org.opencontainers.image.title="TinAI"
LABEL org.opencontainers.image.description="llama.cpp + Open WebUI + OpenFang – offline AI stack"
LABEL org.opencontainers.image.source="https://github.com/MX10-AC2N/TinAI"
LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"
LABEL org.opencontainers.image.licenses="MIT"

# Dépendances runtime (curl pour healthchecks, supervisor pour orchestration)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 \
    supervisor procps wget \
    && rm -rf /var/lib/apt/lists/*

# ── llama-server (optimisé AVX/NEON) ─────────────────────────────
COPY --from=llama-builder /src/build/bin/llama-server /usr/local/bin/llama-server

# ── OpenFang (binaire Rust natif) ────────────────────────────────
COPY --from=openfang-builder /openfang-bin /usr/local/bin/openfang

# ── Open WebUI (PyPI — amd64 + arm64 natif) ──────────────────────
RUN pip install --no-cache-dir \
    open-webui \
    huggingface_hub \
    && pip cache purge \
    # Nettoyage agressif : __pycache__, tests, docs inutiles
    && find /usr/local/lib/python3.11 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -type d -name "tests"       -exec rm -rf {} + 2>/dev/null || true \
    && find /usr/local/lib/python3.11 -name "*.pyc"               -delete 2>/dev/null || true

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
    /usr/local/bin/healthcheck.sh \
    /usr/local/bin/openfang

# ── Variables d'environnement par défaut ──────────────────────────
ENV LLAMA_MODEL_PATH=/data/models/model.gguf \
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
