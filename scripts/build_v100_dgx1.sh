#!/bin/bash
# ==============================================================================
# NVIDIA DGX-1 V100 Optimized Builder (Self-Contained)
# Developer: Morph3us Sigma
# ==============================================================================
# Ce script compile NCCL depuis les sources pour les Tesla V100 (SM 7.0).
# ==============================================================================

set -e

# Auto-détection des chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NCCL_SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$NCCL_SRC_DIR/../.." && pwd)"

# On garde le dossier artifacts du projet parent mais sans le nommer explicitement dans le script si possible
# Mais pour DGX-1 on a besoin d'un point de chute.
INSTALL_DIR="$PROJECT_ROOT/artifacts/nccl/$(date +%Y%m%d)-sm70"
CUDA_HOME="/usr/local/cuda-12.4"

echo "🚀 Starting NCCL V100 Optimized Build..."
echo "📍 Source: $NCCL_SRC_DIR"
echo "🛠️ Compiler: $CUDA_HOME/bin/nvcc"
echo "📂 Output: $INSTALL_DIR"

# 1. Préparation de l'environnement
export CUDA_HOME="/usr/local/cuda-12.4"
export PATH="$CUDA_HOME/bin:$PATH"
export NVCC_GENCODE="-gencode=arch=compute_70,code=sm_70"

# 2. Compilation
cd "$NCCL_SRC_DIR"
rm -rf build/
make -j 80 src.build DEBUG=0

# 3. Installation locale vers artefacts
mkdir -p "$INSTALL_DIR"
cp -v build/lib/libnccl.so* "$INSTALL_DIR/"
cp -rv build/include "$INSTALL_DIR/"

# 4. Création du symlink 'latest'
mkdir -p "$PROJECT_ROOT/artifacts/nccl"
rm -f "$PROJECT_ROOT/artifacts/nccl/latest-sm70"
ln -sf "$INSTALL_DIR" "$PROJECT_ROOT/artifacts/nccl/latest-sm70"

echo "==================================================="
echo "✅ NCCL Build Successful for SM 7.0 (Volta)"
echo "   Artifacts saved in: $INSTALL_DIR"
echo "   Symlink updated: artifacts/nccl/latest-sm70"
echo "==================================================="
