#!/bin/bash
# ==============================================================================
# NVIDIA DGX-1 V100 Optimized NCCL System Installer
# Developer: Morph3us Sigma
# ==============================================================================
# Ce script installe la bibliothèque NCCL compilée pour V100 (SM 7.0)
# de manière permanente dans le système.
# ==============================================================================

set -e

# Configuration des chemins
INSTALL_PATH="/usr/local/lib/v100-sm70"
CONF_FILE="/etc/ld.so.conf.d/v100-sm70.conf"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NCCL_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_LIB_DIR="$NCCL_REPO_DIR/build/lib"

echo "🚀 Installation système de NCCL V100 (SM 7.0)..."

# 1. Vérifier la présence du build
if [ ! -f "$BUILD_LIB_DIR/libnccl.so.2.29.3" ]; then
    echo "❌ Erreur: Build NCCL introuvable dans $BUILD_LIB_DIR"
    echo "   Veuillez lancer 'bash scripts/build_v100_dgx1.sh' d'abord."
    exit 1
fi

# 2. Créer le dossier système
echo "📂 Création du dossier : $INSTALL_PATH"
sudo mkdir -p "$INSTALL_PATH"

# 3. Copier les bibliothèques
echo "💾 Copie des fichiers libnccl..."
sudo cp -v "$BUILD_LIB_DIR"/libnccl.so* "$INSTALL_PATH/"

# 4. Configurer ldconfig pour le chargement automatique
# NOTE: On donne la priorité à ce dossier via un fichier de conf dédié
echo "📝 Configuration de ldconfig..."
echo "$INSTALL_PATH" | sudo tee "$CONF_FILE" > /dev/null

# 5. Mettre à jour le cache des bibliothèques
echo "🔄 Mise à jour du cache système (ldconfig)..."
sudo ldconfig

echo "==================================================="
echo "✅ NCCL V100 installé avec succès !"
echo "   Chemin : $INSTALL_PATH"
echo "   Config : $CONF_FILE"
echo "==================================================="
echo "💡 Les applications (vLLM, PyTorch) utiliseront"
echo "   automatiquement ce build optimisé par Morph3us Sigma."
