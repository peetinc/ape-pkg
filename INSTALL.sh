#!/bin/bash
# Installation script for apepkg dependencies on Linux

set -e

echo "Installing apepkg dependencies..."

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
    echo "Detected Debian/Ubuntu system"
elif [ -f /etc/redhat-release ]; then
    OS="redhat"
    echo "Detected Red Hat/Fedora/CentOS system"
else
    echo "Unsupported operating system"
    exit 1
fi

# Install system dependencies
if [ "$OS" = "debian" ]; then
    echo "Installing build dependencies..."
    sudo apt-get update
    sudo apt-get install -y build-essential libssl-dev libz-dev git autoconf automake libtool
elif [ "$OS" = "redhat" ]; then
    echo "Installing build dependencies..."
    sudo dnf install -y gcc make openssl-devel zlib-devel git autoconf automake libtool
fi

# Create temporary directory
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Install bomutils
echo "Installing bomutils..."
git clone https://github.com/hogliux/bomutils.git
cd bomutils
make
sudo make install
cd ..

# Install xar
echo "Installing xar..."
git clone https://github.com/mackyle/xar.git
cd xar/xar
./autogen.sh
./configure
make
sudo make install
cd ../..

# Cleanup
cd - > /dev/null
rm -rf "$TMPDIR"

# Update library cache (Linux)
if [ "$OS" = "debian" ]; then
    sudo ldconfig
elif [ "$OS" = "redhat" ]; then
    sudo ldconfig
fi

echo ""
echo "Installation complete!"
echo ""
echo "Verify installation:"
echo "  which mkbom lsbom xar"
echo ""
echo "Optional: Install PyYAML for YAML build-info support:"
echo "  pip install PyYAML"
echo ""
echo "You can now use apepkg to build macOS packages on Linux."
