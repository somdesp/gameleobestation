#!/bin/bash
# Instala os apps da lista /etc/gameleobestation/apps.list uma unica vez.
set -u
MARCA=/var/lib/gameleobestation/apps-instalados
LISTA=/etc/gameleobestation/apps.list

[ -f "$MARCA" ] && exit 0

flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

grep -vE '^\s*(#|$)' "$LISTA" | while read -r app; do
    flatpak install --system --noninteractive -y flathub "$app" || echo "Falhou: $app" >> /var/lib/gameleobestation/erros.log
done

mkdir -p /var/lib/gameleobestation
touch "$MARCA"
