#!/bin/bash
# Personalizacoes do GameLeoBeStation. Roda durante a construcao da imagem no GitHub.
set -ouex pipefail

# Copia os arquivos de system_files/ para dentro do sistema
cp -avf "/ctx/system_files"/. /

# ---- Identidade da distro (nome que aparece no sistema) ----
# So mudamos o nome "bonito"; os IDs internos ficam como Bazzite
# para nao quebrar as atualizacoes e os comandos "ujust".
if [ -f /usr/lib/os-release ]; then
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="GameLeoBeStation (baseado no Bazzite)"/' /usr/lib/os-release
fi

# ---- Pacotes extras do sistema (opcional) ----
# Exemplo: dnf5 install -y nome-do-pacote

# ---- Tela de carregamento do boot (Plymouth) ----
dnf5 install -y plymouth-plugin-script
plymouth-set-default-theme gameleobestation
# O tema fica dentro do initramfs, entao ele precisa ser regerado
KVER="$(ls /usr/lib/modules | head -n1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KVER" --reproducible -v --add ostree -f "/usr/lib/modules/$KVER/initramfs.img"
chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"

# ---- Video de abertura do Steam Gaming Mode ----
chmod +x /usr/libexec/gameleo-startup-movie.sh
systemctl --global enable gameleo-startup-movie.service

# ---- Central de acesso remoto (comando: gameleo-remoto) ----
chmod +x /usr/bin/gameleo-remoto

# ---- Servico que instala os launchers de jogos no primeiro boot ----
chmod +x /usr/libexec/gameleo-firstboot-apps.sh
systemctl enable gameleo-firstboot-apps.service

# ---- Repositorios do Fedora para o gerador de ISO ----
# A partir do Fedora 45 os arquivos .repo ficam em /usr/share/dnf5/repos.d,
# mas o gerador de ISO (bootc-image-builder) so le /etc/yum.repos.d.
# Sem isso a ISO falha com "missing packages: coreutils, glibc, systemd...".
if [ -d /usr/share/dnf5/repos.d ]; then
    for f in /usr/share/dnf5/repos.d/fedora*.repo; do
        if [ -e "$f" ] && [ ! -e "/etc/yum.repos.d/$(basename "$f")" ]; then
            cp "$f" /etc/yum.repos.d/
        fi
    done
fi
