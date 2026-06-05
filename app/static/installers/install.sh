#!/bin/sh
set -e

REPO="42Wor/maazdb-cli"
VERSION="13.6.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

printf "%b\n" "${BLUE}=== MaazDB Unix Installer ===${NC}"

if [ "$(id -u)" -eq 0 ]; then
    IS_ROOT=true
    INSTALL_DIR="/usr/local/bin"
    ICON_DIR="/usr/share/pixmaps"
    APP_DIR="/usr/share/applications"
    printf "%b\n" "-> Installing system-wide (Admin Mode)"
else
    IS_ROOT=false
    INSTALL_DIR="$HOME/.maazdb/bin"
    ICON_DIR="$HOME/.local/share/pixmaps"
    APP_DIR="$HOME/.local/share/applications"
    printf "%b\n" "-> Installing user-local (Local Mode)"
fi

OS_TYPE="$(uname -s)"
ARCH_TYPE="$(uname -m)"

if [ "$OS_TYPE" = "Linux" ]; then
    PLATFORM="linux"
elif [ "$OS_TYPE" = "Darwin" ]; then
    PLATFORM="macos"
else
    printf "%b\n" "${RED}Error: Unsupported operating system ($OS_TYPE)${NC}"
    exit 1
fi

case "$ARCH_TYPE" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) ARCH="amd64" ;;
esac

TARGET="maazdb-${PLATFORM}-${ARCH}"
TAR_FILE="${TARGET}.tar.gz"
TMP_DIR=$(mktemp -d)

printf "%b\n" "-> Fetching latest build for ${PLATFORM}-${ARCH}..."
DOWNLOAD_URL="https://github.com/$REPO/releases/download/v$VERSION/$TAR_FILE"

if ! curl -sSL --connect-timeout 10 "$DOWNLOAD_URL" -o "$TMP_DIR/$TAR_FILE"; then
    printf "%b\n" "${RED}Error: Failed to download release bundle.${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

tar -xzf "$TMP_DIR/$TAR_FILE" -C "$TMP_DIR"
EXTRACTED_FOLDER="$TMP_DIR/$TARGET"

# Stop existing services and processes before copying
printf "%b\n" "-> Stopping active MaazDB processes..."
if [ "$PLATFORM" = "linux" ]; then
    if [ "$IS_ROOT" = "true" ]; then
        systemctl stop maazdb.service 2>/dev/null || true
    else
        systemctl --user stop maazdb.service 2>/dev/null || true
    fi
fi
# Kill any lingering foreground processes to release file locks
pkill -f maazdb-server || true
pkill -f maazdb-cli || true
sleep 1

mkdir -p "$INSTALL_DIR"

printf "%b\n" "-> Deploying executables to $INSTALL_DIR..."
if [ -f "$EXTRACTED_FOLDER/maazdb-server" ]; then
    rm -f "$INSTALL_DIR/maazdb-server"
    cp "$EXTRACTED_FOLDER/maazdb-server" "$INSTALL_DIR/"
    chmod 0755 "$INSTALL_DIR/maazdb-server"
fi

if [ -f "$EXTRACTED_FOLDER/maazdb-cli" ]; then
    rm -f "$INSTALL_DIR/maazdb-cli"
    cp "$EXTRACTED_FOLDER/maazdb-cli" "$INSTALL_DIR/"
    chmod 0755 "$INSTALL_DIR/maazdb-cli"
fi

mkdir -p "$ICON_DIR"
mkdir -p "$APP_DIR"

if [ -f "$EXTRACTED_FOLDER/maazdb.ico" ]; then
    cp "$EXTRACTED_FOLDER/maazdb.ico" "$ICON_DIR/"
fi

if [ "$PLATFORM" = "linux" ] && [ -f "$EXTRACTED_FOLDER/maazdb.desktop" ]; then
    sed -e "s|__EXEC__|$INSTALL_DIR/maazdb-cli|g" \
        -e "s|__ICON__|$ICON_DIR/maazdb.ico|g" \
        "$EXTRACTED_FOLDER/maazdb.desktop" > "$APP_DIR/maazdb.desktop"
    chmod 0755 "$APP_DIR/maazdb.desktop"
fi

# Systemd Registration & Restart
if [ "$PLATFORM" = "linux" ] && [ -f "$INSTALL_DIR/maazdb-server" ]; then
    printf "%b\n" "-> Configuring background service..."
    if [ "$IS_ROOT" = "true" ]; then
        SERVICE_FILE="/etc/systemd/system/maazdb.service"
        cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=MaazDB High-Performance Server
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/maazdb-server
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable maazdb.service || true
        systemctl start maazdb.service || true
    else
        USER_SERVICE_DIR="$HOME/.config/systemd/user"
        mkdir -p "$USER_SERVICE_DIR"
        cat <<EOF > "$USER_SERVICE_DIR/maazdb.service"
[Unit]
Description=MaazDB User Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/maazdb-server
Restart=on-failure

[Install]
WantedBy=default.target
EOF
        systemctl --user daemon-reload
        systemctl --user enable maazdb.service || true
        systemctl --user start maazdb.service || true
    fi
fi

rm -rf "$TMP_DIR"

SHELL_NAME="$(basename "$SHELL")"
case "$SHELL_NAME" in
    zsh) PROFILE_PATH="$HOME/.zshrc" ;;
    bash) PROFILE_PATH="$HOME/.bashrc" ;;
    *) PROFILE_PATH="$HOME/.profile" ;;
esac

if [ "$IS_ROOT" = "false" ] && [ -f "$PROFILE_PATH" ]; then
    if ! grep -q "$INSTALL_DIR" "$PROFILE_PATH"; then
        echo "" >> "$PROFILE_PATH"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$PROFILE_PATH"
        printf "%b\n" "${YELLOW}👉 Run: 'source $PROFILE_PATH' or reload your shell to activate PATH updates.${NC}"
    fi
fi

printf "%b\n" "${GREEN}✓ Installation complete!${NC}"