#!/bin/bash
# Personalizacoes do GameLeoBeStation. Roda durante a construcao da imagem no GitHub.
set -ouex pipefail

# Copia os arquivos de system_files/ para dentro do sistema
cp -avf "/ctx/system_files"/. /

# ---- Identidade da distro ----
# So mudamos o nome "bonito"; os IDs internos ficam como Bazzite
# para nao quebrar as atualizacoes e os comandos "ujust".
if [ -f /usr/lib/os-release ]; then
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="GameLeoBeStation (baseado no Bazzite)"/' /usr/lib/os-release
fi

# ---- Heronite: launcher principal (todas as lojas num lugar so) ----
# Pega a versao mais nova publicada; se a consulta falhar, usa a 1.1.1.
HERONITE_RPM=$(curl -fsSL https://api.github.com/repos/RafaelGoulartB/Heronite/releases/latest \
    | grep -oE 'https://[^"]+x86_64\.rpm' | head -n1 || true)
if [ -z "$HERONITE_RPM" ]; then
    HERONITE_RPM="https://github.com/RafaelGoulartB/Heronite/releases/download/v1.1.1/heronite-1.1.1-1.x86_64.rpm"
fi
dnf5 install -y "$HERONITE_RPM"
# Extras que o Heronite usa: janela de login das lojas, downloads do GOG, sandbox
dnf5 install -y --skip-unavailable webkit2gtk4.1 python3 bubblewrap
test -x /usr/bin/heronite-rs

chmod +x /usr/bin/gameleo-console /usr/bin/gameleo-remoto
chmod +x /usr/libexec/gameleo-autologin.sh /usr/libexec/gameleo-firstboot-apps.sh
systemctl enable gameleo-autologin.service
systemctl enable gameleo-firstboot-apps.service

# ---- Tela de carregamento do boot (Plymouth) com a animacao GameLeoBeStation ----
dnf5 install -y plymouth-plugin-script
plymouth-set-default-theme gameleobestation

# O tema fica dentro do initramfs, entao ele precisa ser regerado.
# Usamos exatamente os mesmos parametros do Bazzite, para nao perder
# nada que ele coloca no initramfs (incluindo firmware de placa de video).
KVER="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel | tail -n1)"
INITRAMFS="/usr/lib/modules/${KVER}/initramfs.img"

# Guarda o que o initramfs original do Bazzite tinha de firmware AMD (RDNA4 = RX 9060/9070)
ORIG_AMD=0
if [ -f "$INITRAMFS" ] && lsinitrd "$INITRAMFS" 2>/dev/null | grep -E 'amdgpu/(gc_12_0_|sdma_7_0_)' >/dev/null; then
    ORIG_AMD=1
fi

DRACUT_NO_XATTR=1 /usr/bin/dracut \
    --no-hostonly \
    --kver "${KVER}" \
    --reproducible \
    --zstd \
    -v \
    --add ostree \
    --add fido2 \
    -f "${INITRAMFS}"
chmod 0600 "${INITRAMFS}"

# ---- Verificacao da placa de video (RX 9060 XT) ----
# O firmware precisa existir no sistema...
if ! ls /usr/lib/firmware/amdgpu/ | grep -E '^gc_12_0_0' >/dev/null; then
    echo "ERRO: firmware da RX 9060 XT (gc_12_0_0) nao encontrado na imagem" >&2
    exit 1
fi
# ...e, se o initramfs original tinha, o novo tambem precisa ter.
if [ "$ORIG_AMD" = 1 ] && ! lsinitrd "$INITRAMFS" | grep -E 'amdgpu/(gc_12_0_|sdma_7_0_)' >/dev/null; then
    echo "ERRO: o initramfs novo perdeu o firmware AMD que o original tinha" >&2
    exit 1
fi
