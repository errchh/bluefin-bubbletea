#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Install base shell tools
dnf5 install -y tmux

# Install Traditional Chinese Input Method Engines, Fonts, Locales, and GTK Bridges
dnf5 install -y \
    ibus-chewing \
    ibus-libzhuyin \
    ibus-cangjie \
    ibus-table-chinese-cangjie \
    ibus-table-chinese-quick \
    ibus-table-chinese-stroke5 \
    ibus-gtk3 \
    ibus-gtk4 \
    google-noto-sans-tc-fonts \
    google-noto-serif-tc-fonts \
    google-noto-sans-mono-cjk-tc-fonts \
    google-noto-sans-hk-fonts \
    google-noto-serif-hk-fonts \
    google-noto-sans-mono-cjk-hk-fonts \
    glibc-langpack-zh

### Configure GNOME Defaults (Vendor Schema Override)

# Create schema directory if it doesn't exist and write default input sources
mkdir -p /usr/share/glib-2.0/schemas/
cat <<EOF > /usr/share/glib-2.0/schemas/90_bluefin-zh.gschema.override
[org.gnome.desktop.input-sources]
sources=[('xkb', 'us'), ('ibus', 'chewing')]
EOF

# Recompile GSettings schemas to apply defaults natively
glib-compile-schemas /usr/share/glib-2.0/schemas

#### Example for enabling a System Unit File

systemctl enable podman.socket
