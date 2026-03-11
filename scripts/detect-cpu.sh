#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  detect-cpu.sh — Détection des capacités CPU pour llama.cpp
#  Usage (build) : cmake $(./detect-cpu.sh --cmake)
#  Usage (info)  : ./detect-cpu.sh
#  Retourne les flags cmake optimaux selon l'architecture et les
#  extensions SIMD disponibles sur le CPU courant.
# ══════════════════════════════════════════════════════════════════

ARCH=$(uname -m)
CMAKE_FLAGS=""
SUMMARY=""

# ── x86_64 ────────────────────────────────────────────────────────
if [ "${ARCH}" = "x86_64" ]; then
    FLAGS=$(grep -m1 "^flags" /proc/cpuinfo 2>/dev/null | cut -d: -f2)

    has() { echo "${FLAGS}" | grep -qw "$1"; }

    # Détection hiérarchique — du plus puissant au plus basique
    if has avx512f && has avx512bw && has avx512vl; then
        CMAKE_FLAGS="-DGGML_AVX=ON -DGGML_AVX2=ON -DGGML_AVX512=ON -DGGML_FMA=ON -DGGML_F16C=ON"
        SUMMARY="AVX-512 (serveur/Xeon/Zen4 — performances maximales)"
    elif has avx2 && has fma; then
        CMAKE_FLAGS="-DGGML_AVX=ON -DGGML_AVX2=ON -DGGML_FMA=ON -DGGML_F16C=ON"
        SUMMARY="AVX2+FMA (Haswell+, Ryzen — très bonnes performances)"
    elif has avx; then
        CMAKE_FLAGS="-DGGML_AVX=ON -DGGML_AVX2=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF"
        SUMMARY="AVX (Sandy Bridge/Ivy Bridge — bonnes performances)"
    elif has sse4_2; then
        CMAKE_FLAGS="-DGGML_AVX=OFF -DGGML_AVX2=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF"
        SUMMARY="SSE4.2 uniquement (Atom/Celeron/N-series — compatible Zimaboard)"
    elif has sse4_1; then
        CMAKE_FLAGS="-DGGML_AVX=OFF -DGGML_AVX2=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF -DGGML_SSE42=OFF"
        SUMMARY="SSE4.1 (CPU très ancien — performances réduites)"
    else
        CMAKE_FLAGS="-DGGML_AVX=OFF -DGGML_AVX2=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF"
        SUMMARY="Baseline x86_64 (aucune extension SIMD détectée)"
    fi

# ── ARM64 ─────────────────────────────────────────────────────────
elif [ "${ARCH}" = "aarch64" ] || [ "${ARCH}" = "arm64" ]; then
    FLAGS=$(grep -m1 "^Features" /proc/cpuinfo 2>/dev/null | cut -d: -f2)

    has() { echo "${FLAGS}" | grep -qw "$1"; }

    if has sve; then
        CMAKE_FLAGS="-DGGML_NEON=ON -DGGML_SVE=ON"
        SUMMARY="NEON+SVE (Graviton3, Neoverse N2 — performances maximales ARM)"
    elif has asimddp; then
        CMAKE_FLAGS="-DGGML_NEON=ON -DGGML_DOTPROD=ON"
        SUMMARY="NEON+DotProd (Cortex-A55/A76, Apple M-series, RPi 4/5)"
    else
        CMAKE_FLAGS="-DGGML_NEON=ON"
        SUMMARY="NEON (ARM64 générique)"
    fi

# ── Inconnu ───────────────────────────────────────────────────────
else
    CMAKE_FLAGS=""
    SUMMARY="Architecture inconnue (${ARCH}) — build générique"
fi

# ── Sortie ────────────────────────────────────────────────────────
if [ "${1}" = "--cmake" ]; then
    # Mode silencieux pour intégration cmake
    echo "${CMAKE_FLAGS}"
elif [ "${1}" = "--summary" ]; then
    echo "${SUMMARY}"
else
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  TinAI — Détection CPU                                   ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    printf  "║  Architecture : %-41s║\n" "${ARCH}"
    printf  "║  Profil       : %-41s║\n" "${SUMMARY}"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  Flags cmake  :                                          ║"
    for flag in ${CMAKE_FLAGS}; do
        printf "║    %-54s║\n" "${flag}"
    done
    echo "╚══════════════════════════════════════════════════════════╝"
fi
