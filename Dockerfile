# ══════════════════════════════════════════════════════════════════
#  TinAI – Image principale (llama.cpp + OpenFang)
#  Cibles : linux/amd64 · linux/arm64
#  Open WebUI est désormais dans son propre conteneur (Dockerfile.webui)
#  Modèle  : configurable via LLAMA_HF_* (téléchargé au 1er run)
# ══════════════════════════════════════════════════════════════════
ARG TARGETARCH
ARG TARGETPLATFORM

# ══════════════════════════════════════════════════════════════════
#  Étape 1 : Build llama.cpp (optimisé AVX/NEON selon arch)
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
        CMAKE_EXTRA="-DGGML_NEON=ON"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
        # SSE4.2 uniquement — compatible Atom/Celeron/Pentium (Gemini Lake, Bay Trail…)
        # AVX désactivé : non supporté sur Intel N3xxx/N4xxx/J4xxx
        CMAKE_EXTRA="-DGGML_AVX=OFF -DGGML_AVX2=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF"; \
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
#  Étape 2 : Build OpenFang (binaire Rust)
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim AS openfang-builder
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git build-essential ca-certificates \
    libssl-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile minimal
ENV PATH="/root/.cargo/bin:$PATH"

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
#  Étape 3 : Image finale – runtime minimal (pas de Python/pip)
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim

ARG TARGETARCH
ARG TARGETPLATFORM

LABEL org.opencontainers.image.title="TinAI"
LABEL org.opencontainers.image.description="llama.cpp + OpenFang – offline AI backend"
LABEL org.opencontainers.image.source="https://github.com/MX10-AC2N/TinAI"
LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 \
    supervisor procps wget \
    && rm -rf /var/lib/apt/lists/*

# ── Binaires compilés ─────────────────────────────────────────────
COPY --from=llama-builder    /src/build/bin/llama-server /usr/local/bin/llama-server
COPY --from=openfang-builder /openfang-bin               /usr/local/bin/openfang

RUN chmod +x /usr/local/bin/llama-server /usr/local/bin/openfang

# ── Répertoires de données ────────────────────────────────────────
RUN mkdir -p \
    /data/models \
    /root/.openfang \
    /var/log/tinai

# ── Scripts & config ──────────────────────────────────────────────
COPY scripts/start-llama.sh    /usr/local/bin/start-llama.sh
COPY scripts/start-openfang.sh /usr/local/bin/start-openfang.sh
COPY scripts/healthcheck.sh    /usr/local/bin/healthcheck.sh
COPY supervisord.conf          /etc/supervisor/conf.d/tinai.conf

RUN chmod +x \
    /usr/local/bin/start-llama.sh \
    /usr/local/bin/start-openfang.sh \
    /usr/local/bin/healthcheck.sh

# ── Variables d'environnement ─────────────────────────────────────
ENV LLAMA_MODEL_PATH=/data/models/model.gguf \
    LLAMA_HF_REPO=Qwen/Qwen3-1.7B-GGUF \
    LLAMA_HF_FILE=qwen3-1.7b-q5_k_m.gguf \
    LLAMA_CTX_SIZE=8192 \
    LLAMA_THREADS=4 \
    LLAMA_GPU_LAYERS=0 \
    LLAMA_PORT=8081 \
    OPENFANG_PORT=4200 \
    TINAI_API_KEY=sk-tinai \
    DATA_DIR=/data \
    HOME=/root

VOLUME ["/data/models", "/root/.openfang"]

EXPOSE 4200 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/tinai.conf"]
