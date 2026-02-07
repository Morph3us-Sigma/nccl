#!/bin/bash
# ==============================================================================
# NVIDIA DGX-1 NCCL Debian Packager
# Developer: Morph3us Sigma
# ==============================================================================
# Ce script génère un paquet .deb pour NCCL optimisé pour V100 (SM 7.0).
# ==============================================================================

set -e

# Configuration
PKG_NAME="nccl-v100-sm70"
PKG_VERSION="2.29.3-1"
PKG_ARCH="amd64"
PKG_DIR_NAME="${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NCCL_REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_LIB_DIR="$NCCL_REPO_DIR/build/lib"
BUILD_INC_DIR="$NCCL_REPO_DIR/build/include"
DIST_DIR="$NCCL_REPO_DIR/dist"

TEMP_PKG_DIR="/tmp/$PKG_DIR_NAME"

echo "📦 Préparation du paquet Debian : $PKG_NAME..."

# 1. Nettoyage et création de l'arborescence
rm -rf "$TEMP_PKG_DIR"
mkdir -p "$TEMP_PKG_DIR/DEBIAN"
mkdir -p "$TEMP_PKG_DIR/usr/local/lib/$PKG_NAME"
mkdir -p "$TEMP_PKG_DIR/usr/local/include/$PKG_NAME"
mkdir -p "$TEMP_PKG_DIR/etc/ld.so.conf.d"

# 2. Copie des fichiers
echo "💾 Copie des fichiers de build..."
if [ ! -d "$BUILD_LIB_DIR" ]; then
    echo "❌ Erreur: Build introuvable. Lancez 'bash scripts/build_v100_dgx1.sh' d'abord."
    exit 1
fi

cp -P "$BUILD_LIB_DIR"/libnccl.so* "$TEMP_PKG_DIR/usr/local/lib/$PKG_NAME/"
cp -r "$BUILD_INC_DIR"/* "$TEMP_PKG_DIR/usr/local/include/$PKG_NAME/"

# 3. Création du fichier de configuration ldconfig
echo "/usr/local/lib/$PKG_NAME" > "$TEMP_PKG_DIR/etc/ld.so.conf.d/$PKG_NAME.conf"

# 4. Création du fichier CONTROL
echo "📝 Génération du fichier DEBIAN/control..."
cat <<EOF > "$TEMP_PKG_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $PKG_VERSION
Section: libs
Priority: optional
Architecture: $PKG_ARCH
Maintainer: Morph3us Sigma
Description: Optimized NCCL for NVIDIA DGX-1 (Tesla V100 SM7.0)
 This package contains the custom NCCL build optimized for Volta architecture
 on DGX-1 clusters. Maintained by Morph3us Sigma.
EOF

# 5. Script post-installation (ldconfig)
echo "📜 Génération du script postinst..."
cat <<EOF > "$TEMP_PKG_DIR/DEBIAN/postinst"
#!/bin/bash
set -e
echo "🔄 Mise à jour du cache des bibliothèques (ldconfig)..."
ldconfig
echo "✅ NCCL V100 (SM 7.0) est maintenant actif sur le système."
EOF
chmod 755 "$TEMP_PKG_DIR/DEBIAN/postinst"

# 6. Script post-suppression (ldconfig)
echo "📜 Génération du script postrm..."
cat <<EOF > "$TEMP_PKG_DIR/DEBIAN/postrm"
#!/bin/bash
set -e
echo "🔄 Nettoyage du cache des bibliothèques..."
ldconfig
EOF
chmod 755 "$TEMP_PKG_DIR/DEBIAN/postrm"

# 7. Construction du paquet
echo "🏗️ Construction du .deb..."
mkdir -p "$DIST_DIR"
dpkg-deb --build "$TEMP_PKG_DIR" "$DIST_DIR/$PKG_DIR_NAME.deb"

echo "==================================================="
echo "✅ Paquet Debian généré avec succès !"
echo "   Fichier : $DIST_DIR/$PKG_DIR_NAME.deb"
echo "==================================================="
echo "💡 Pour installer : sudo dpkg -i $DIST_DIR/$PKG_DIR_NAME.deb"
