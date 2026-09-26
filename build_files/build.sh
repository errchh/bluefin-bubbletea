#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Install base shell tools
dnf5 install -y tmux

# Install Traditional Chinese Input Methods & Locales
dnf5 install -y --skip-unavailable \
    ibus-chewing \
    ibus-libzhuyin \
    ibus-cangjie \
    ibus-table-chinese-cangjie \
    ibus-table-chinese-quick \
    ibus-table-chinese-stroke5 \
    google-noto-sans-cjk-vf-fonts \
    google-noto-serif-cjk-vf-fonts \
    glibc-langpack-zh \
    glibc-langpack-en

### Configure GNOME Defaults (Vendor Schema Override)

# Create schema directory if it doesn't exist and set US Keymap + Cangjie 5 as defaults
mkdir -p /usr/share/glib-2.0/schemas/
cat <<EOF > /usr/share/glib-2.0/schemas/90_bluefin-zh.gschema.override
[org.gnome.desktop.input-sources]
sources=[('xkb', 'us'), ('ibus', 'cangjie5')]

[system.locale]
region='en_GB.UTF-8'
EOF

# Recompile GSettings schemas to apply defaults natively
glib-compile-schemas /usr/share/glib-2.0/schemas

#### Enable System Unit File
systemctl enable podman.socket
