#!/bin/bash
# Login automatico no primeiro usuario, para o PC ligar direto no Heronite.
# Para desligar: sudo touch /etc/gameleobestation/no-autologin
set -u
CONF=/etc/sddm.conf.d/zz-gameleobestation.conf

if [ -e /etc/gameleobestation/no-autologin ]; then
    rm -f "$CONF"
    exit 0
fi

USUARIO=$(getent passwd | awk -F: '$3>=1000 && $3<60000 && $7 !~ /(nologin|false)$/ {print $1; exit}')
[ -n "$USUARIO" ] || exit 0

SESSAO=plasma
for s in plasma plasmawayland; do
    if [ -f "/usr/share/wayland-sessions/$s.desktop" ]; then SESSAO=$s; break; fi
done

mkdir -p /etc/sddm.conf.d
NOVO="[Autologin]
User=$USUARIO
Session=$SESSAO
Relogin=false"
if [ ! -f "$CONF" ] || [ "$(cat "$CONF")" != "$NOVO" ]; then
    printf '%s\n' "$NOVO" > "$CONF"
fi
