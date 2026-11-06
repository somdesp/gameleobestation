#!/bin/bash
# Login automatico no primeiro usuario, para o PC ligar direto no Heronite.
# Funciona com o Plasma Login Manager (Bazzite 44+) e com o SDDM.
# Para desligar: sudo touch /etc/gameleobestation/no-autologin
set -u
CONF_PLM=/etc/plasmalogin.conf.d/zz-gameleobestation.conf
CONF_SDDM=/etc/sddm.conf.d/zz-gameleobestation.conf

if [ -e /etc/gameleobestation/no-autologin ]; then
    rm -f "$CONF_PLM" "$CONF_SDDM"
    exit 0
fi

USUARIO=$(getent passwd | awk -F: '$3>=1000 && $3<60000 && $7 !~ /(nologin|false)$/ {print $1; exit}')
[ -n "$USUARIO" ] || exit 0

SESSAO=plasma.desktop
for s in plasma plasmawayland; do
    if [ -f "/usr/share/wayland-sessions/$s.desktop" ]; then SESSAO="$s.desktop"; break; fi
done

escreve() {
    local arquivo="$1" conteudo="$2"
    mkdir -p "$(dirname "$arquivo")"
    if [ ! -f "$arquivo" ] || [ "$(cat "$arquivo")" != "$conteudo" ]; then
        printf '%s\n' "$conteudo" > "$arquivo"
    fi
}

# Plasma Login Manager: Relogin=true evita um bug do autologin na versao 6.7
escreve "$CONF_PLM" "[Autologin]
User=$USUARIO
Session=$SESSAO
Relogin=true"

# SDDM (versoes antigas)
escreve "$CONF_SDDM" "[Autologin]
User=$USUARIO
Session=$SESSAO
Relogin=false"
