# ══════════════════════════════════════════════════════════════════
#  TinAI – Image unique multi-architecture
#  Cibles : linux/amd64 · linux/arm64
#  Contenu : llama.cpp + Open CoreUI (Rust) + OpenFang (Rust)
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
#  Étape 3 : Téléchargement Open CoreUI (binaire Rust ~60 MB)
#  Releases : https://github.com/xxnuo/open-coreui/releases
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim AS coreui-fetcher
ARG TARGETARCH

# Version figée — à bumper manuellement lors des releases
ARG COREUI_VERSION=0.9.6

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) TRIPLE="x86_64-unknown-linux-gnu" ;; \
        arm64) TRIPLE="aarch64-unknown-linux-gnu" ;; \
        *) echo "Architecture non supportée : ${TARGETARCH}" && exit 1 ;; \
    esac; \
    curl -fSL \
        "https://github.com/xxnuo/open-coreui/releases/download/v${COREUI_VERSION}/open-coreui-${COREUI_VERSION}-${TRIPLE}" \
        -o /coreui-bin \
    && chmod +x /coreui-bin

# ══════════════════════════════════════════════════════════════════
#  Étape 4 : Image finale (debian slim — plus de Python !)
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim

ARG TARGETARCH
ARG TARGETPLATFORM
ARG COREUI_VERSION=0.9.6

LABEL org.opencontainers.image.title="TinAI"
LABEL org.opencontainers.image.description="llama.cpp + Open CoreUI + OpenFang – offline AI stack"
LABEL org.opencontainers.image.source="https://github.com/MX10-AC2N/TinAI"
LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"
LABEL org.opencontainers.image.licenses="MIT"

# Runtime minimal : curl (healthchecks), supervisor, wget (fallback download), libssl
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 \
    supervisor procps wget python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# huggingface_hub pour le téléchargement du modèle (bien plus léger que open-webui)
RUN pip3 install --no-cache-dir --break-system-packages huggingface_hub \
    && pip3 cache purge

# ── Binaires ──────────────────────────────────────────────────────
COPY --from=llama-builder    /src/build/bin/llama-server /usr/local/bin/llama-server
COPY --from=openfang-builder /openfang-bin               /usr/local/bin/openfang
COPY --from=coreui-fetcher   /coreui-bin                 /usr/local/bin/open-coreui

RUN chmod +x \
    /usr/local/bin/llama-server \
    /usr/local/bin/openfang \
    /usr/local/bin/open-coreui

# ── Répertoires de données ────────────────────────────────────────
RUN mkdir -p \
    /data/models \
    /data/coreui \
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

# ── Variables d'environnement ─────────────────────────────────────
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
    COREUI_VERSION=${COREUI_VERSION} \
    DATA_DIR=/data

VOLUME ["/data/models", "/data/coreui", "/data/openfang"]

EXPOSE 3000 4200 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/tinai.conf"]
