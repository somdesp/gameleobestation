# GameLeoBeStation

Linux para jogos baseado no Bazzite, feito para GPU AMD (Radeon RX 9060 XT 16 GB).
O PC liga, mostra a animacao GameLeoBeStation e entra direto no **Heronite em modo console**:
uma biblioteca so com Steam, Epic, GOG, Amazon, Battle.net, EA, Ubisoft, Rockstar e emuladores,
controlada pelo controle.

## O que vem nele

- Animacao propria no boot (Plymouth), feita a partir do GIF GameLeoBeStation
- Login automatico e Heronite em tela cheia, modo console
- Steam instalado (aparece dentro do Heronite como mais uma loja)
- Backup automatico dos saves (Ludusavi, instalado no primeiro boot com internet)
- Central de acesso remoto (menu "Acesso Remoto" ou comando `gameleo-remoto`)
- Atualizacoes automaticas: cada vez que a imagem e reconstruida no GitHub, o PC recebe

## Como instalar

A instalacao e feita com a ISO **oficial** do Bazzite (testada e com suporte a RX 9060 XT)
e depois o sistema e trocado para a GameLeoBeStation.

1. Em https://bazzite.gg baixe a versao **Desktop**, GPU **AMD**, area de trabalho **KDE Plasma**
   (nao escolha a opcao "Steam Gaming Mode"/HTPC).
2. Grave no pendrive (Ventoy, balenaEtcher ou Rufus) e instale. Na primeira tela escolha
   **Portugues (Brasil)**; confira teclado ABNT2 e fuso de Sao Paulo.
3. Depois de entrar no sistema, abra o **Konsole** (terminal) e rode:

       sudo bootc switch ghcr.io/somdesp/gameleobestation:latest

   Se der erro de assinatura, use:

       sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/somdesp/gameleobestation:latest

4. Reinicie: `systemctl reboot`. A partir dai o PC liga direto no Heronite.

O pacote `gameleobestation` precisa estar **publico** no GitHub (Packages > Package settings).

## Dicas

- Sair do modo console para a area de trabalho: feche o Heronite. Para voltar, abra
  "Modo Console (Heronite)" no menu.
- A tela nao bloqueia sozinha nem pede senha ao voltar da suspensao.
- Desligar o login automatico: `sudo touch /etc/gameleobestation/no-autologin`
- Apps extras no primeiro boot: edite `system_files/etc/gameleobestation/apps.list`.
- Steam em portugues: Steam > Configuracoes > Interface > Idioma.

## Acesso remoto

Abra **Acesso Remoto** no menu (ou `gameleo-remoto`). Tudo vem desligado; voce ativa o que quiser:
Sunshine + Moonlight (jogar de outro aparelho), Tailscale (fora de casa), SSH e RustDesk.

## Tela de carregamento

Arquivos `frame-0.png` a `frame-8.png` em `system_files/usr/share/plymouth/themes/gameleobestation/`.
Para trocar a animacao, substitua esses quadros (mesmo nome e quantidade).

## Placa de video

O build confere se o firmware da RX 9060 XT esta na imagem e no initramfs; se faltar,
o build falha antes de publicar uma imagem que daria tela preta.
