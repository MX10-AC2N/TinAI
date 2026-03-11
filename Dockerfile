# ══════════════════════════════════════════════════════════════════
#  TinAI v5 – Image principale (OpenFang uniquement)
#  llama.cpp → image officielle ghcr.io/ggml-org/llama.cpp:server
#  Cibles : linux/amd64 · linux/arm64
# ══════════════════════════════════════════════════════════════════
ARG TARGETARCH
ARG TARGETPLATFORM

# ══════════════════════════════════════════════════════════════════
#  Étape 1 : Build OpenFang (binaire Rust)
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
#  Étape 2 : Image finale – runtime minimal
# ══════════════════════════════════════════════════════════════════
FROM debian:bookworm-slim

ARG TARGETARCH
ARG TARGETPLATFORM

LABEL org.opencontainers.image.title="TinAI"
LABEL org.opencontainers.image.description="OpenFang AI agent – llama.cpp via image officielle"
LABEL org.opencontainers.image.source="https://github.com/MX10-AC2N/TinAI"
LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 procps \
    && rm -rf /var/lib/apt/lists/*

# ── Binaire OpenFang ──────────────────────────────────────────────
COPY --from=openfang-builder /openfang-bin /usr/local/bin/openfang
RUN chmod +x /usr/local/bin/openfang

# ── Répertoires de données ────────────────────────────────────────
RUN mkdir -p /root/.openfang /var/log/tinai

# ── Scripts ───────────────────────────────────────────────────────
COPY scripts/start-openfang.sh /usr/local/bin/start-openfang.sh
COPY scripts/healthcheck.sh    /usr/local/bin/healthcheck.sh
RUN chmod +x \
    /usr/local/bin/start-openfang.sh \
    /usr/local/bin/healthcheck.sh

# ── Variables d'environnement ─────────────────────────────────────
# TINAI_API_KEY intentionnellement absent — injecté par docker-compose
ENV OPENFANG_PORT=4200 \
    LLAMA_PORT=8081 \
    HOME=/root

VOLUME ["/root/.openfang"]

EXPOSE 4200

HEALTHCHECK --interval=10s --timeout=5s --start-period=25s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/local/bin/start-openfang.sh"]
