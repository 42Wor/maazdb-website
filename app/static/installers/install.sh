#!/bin/bash
set -e 

# --- Settings ---
REPO="42Wor/maazdb-cli"
# Usage for local test: sudo -E LOCAL_DIR=$(pwd)/dist ./install.sh
INSTALL_SOURCE=${LOCAL_DIR:-"download"}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== MaazDB Installation ===${NC}"

# 1. Detect Platform
OS_TYPE="$(uname -s)"
if [ "$OS_TYPE" = "Linux" ]; then PLATFORM="linux"; elif [ "$OS_TYPE" = "Darwin" ]; then PLATFORM="macos"; else echo "Unsupported OS"; exit 1; fi
TARGET="maazdb-${PLATFORM}-amd64"

# 2. Root check
if [ "$EUID" -ne 0 ]; then echo -e "${RED}Please run with sudo${NC}"; exit 1; fi

# 3. Stop existing service to prevent "Text file busy"
if [ -f /etc/systemd/system/maazdb.service ]; then
    echo "-> Stopping existing maazdb service..."
    systemctl stop maazdb || true
fi

# 4. Prepare Files
TMP_DIR=$(mktemp -d)

if [ "$INSTALL_SOURCE" = "download" ]; then
    echo "-> Downloading latest release..."
    DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/${TARGET}.tar.gz"
    curl -sSL "$DOWNLOAD_URL" -o "$TMP_DIR/maazdb.tar.gz"
    tar -xzf "$TMP_DIR/maazdb.tar.gz" -C "$TMP_DIR"
    EXTRACTED_FOLDER="$TMP_DIR/$TARGET"
else
    # Use realpath to ensure the path is absolute and valid
    EXTRACTED_FOLDER="$(realpath "$INSTALL_SOURCE")/$TARGET"
    echo "-> Using local files from $EXTRACTED_FOLDER..."
fi

# Verify the folder exists before proceeding
if [ ! -d "$EXTRACTED_FOLDER" ]; then
    echo -e "${RED}Error: Source folder not found: $EXTRACTED_FOLDER${NC}"
    exit 1
fi

# 5. Install Binaries
echo "-> Installing to /usr/local/bin..."
cp "$EXTRACTED_FOLDER/maazdb-server" /usr/local/bin/
cp "$EXTRACTED_FOLDER/maazdb-cli" /usr/local/bin/
chmod +x /usr/local/bin/maazdb-server /usr/local/bin/maazdb-cli

# 6. Linux Service (Systemd)
if [ "$PLATFORM" = "linux" ]; then
    echo "-> Configuring Systemd service..."
    mkdir -p /var/lib/maazdb
    
    cat > /etc/systemd/system/maazdb.service << EOF
[Unit]
Description=MaazDB Database Server
After=network.target

[Service]
Type=simple
User=${SUDO_USER:-root}
ExecStart=/usr/local/bin/maazdb-server
WorkingDirectory=/var/lib/maazdb
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable maazdb
    systemctl restart maazdb
fi

# 7. Cleanup
rm -rf "$TMP_DIR"

echo -e "${GREEN}Success! MaazDB is installed and running.${NC}"
echo -e "Use ${BLUE}maazdb-cli${NC} to connect."