# GameLeoBeStation

Linux para jogos que liga direto numa interface de console (Steam Gaming Mode), baseado no Bazzite e feito para GPU AMD (testado como alvo: Radeon RX 9060 XT 16 GB).

## O que vem nele

- Inicia direto no Steam Gaming Mode, controlavel por controle, como um console
- Steam com Proton ja configurado
- Heroic Games Launcher (Epic, GOG, Amazon), Lutris (Battle.net, EA, Ubisoft, itch.io e outros), BoilR e ProtonPlus, instalados automaticamente no primeiro boot com internet
- Atualizacoes automaticas: toda vez que o GitHub reconstroi a imagem, seu PC recebe a nova versao
- Modo Desktop (KDE) disponivel pelo menu Power > Switch to Desktop

Para mudar os apps, edite `system_files/etc/gameleobestation/apps.list`.

## Acesso remoto

Abra **Acesso Remoto** no menu do Modo Desktop (ou rode `gameleo-remoto` no terminal). Por seguranca tudo vem desligado, e voce ativa so o que quiser:

1. **Jogar de outro aparelho**: Sunshine no PC + app Moonlight no celular, notebook ou TV. Voce ve a tela e joga com baixa latencia, inclusive no modo console.
2. **Acessar de fora de casa**: Tailscale cria uma rede privada entre seus aparelhos, sem abrir portas no roteador.
3. **Terminal remoto (SSH)**: para manutencao a partir de outro PC.
4. **RustDesk**: controle da area de trabalho com ID e senha, parecido com o AnyDesk.
5. **Desligar tudo** de uma vez.

Tambem funciona direto: `gameleo-remoto sunshine`, `gameleo-remoto tailscale`, `gameleo-remoto ssh`, `gameleo-remoto rustdesk`, `gameleo-remoto status`, `gameleo-remoto desligar`.

## Telas de carregamento

O GameLeoBeStation tem duas animacoes proprias:

- **Boot (Plymouth)**: animacao GameLeoBeStation (9 quadros, a partir do GIF original), enquanto o sistema liga. Arquivos `frame-0.png` a `frame-8.png` em `system_files/usr/share/plymouth/themes/gameleobestation/`.
- **Abertura do Steam**: a mesma animacao em video (cerca de 3,5 segundos), toca toda vez que o Gaming Mode abre. Arquivo em `system_files/usr/share/gameleobestation/deck_startup.webm`. Ele e ativado a partir do segundo boot (depois que o Steam terminar a primeira configuracao). Se nao aparecer, escolha em Configuracoes > Personalizacao > Video de inicializacao.

Para trocar o logo, substitua os PNGs e o .webm por versoes suas com o mesmo nome. Os scripts em `branding/` geram tudo de novo (precisa de Python com Pillow e ffmpeg).

## Passo a passo para gerar a ISO

1. Crie uma conta no GitHub (se nao tiver).
2. Crie um repositorio novo chamado exatamente `gameleobestation` e envie todos estes arquivos para ele (pode arrastar a pasta em "Add file > Upload files"; a pasta `.github` precisa ir junto).
3. Troque `seu-usuario` pelo seu usuario do GitHub (minusculas) em dois arquivos: `image-template.env` e `disk_config/iso.toml`.
4. Va na aba **Actions** e clique para ativar os workflows.
5. Rode **Build container image** (Actions > Build container image > Run workflow). Leva uns 20 a 40 minutos.
6. Deixe a imagem publica: no seu perfil do GitHub, aba **Packages** > `gameleobestation` > Package settings > Change visibility > Public. Sem isso a instalacao e as atualizacoes falham.
7. Rode **Build disk images** (Actions > Build disk images > Run workflow, plataforma amd64).
8. Quando terminar, abra a execucao e baixe os artifacts no final da pagina. O `anaconda-iso` contem o `install.iso`. O `qcow2` e uma imagem pronta para maquina virtual.

## Instalando

Grave o `install.iso` num pendrive (Ventoy ou balenaEtcher), de boot com UEFI ativado e Secure Boot desligado, e siga o instalador. No primeiro boot com internet, os launchers sao instalados sozinhos em segundo plano.

## Depois de instalar

1. Faca login na Steam no Gaming Mode.
2. Va para o Modo Desktop, abra o Heroic e faca login na Epic e GOG.
3. Abra o BoilR e clique em "Synchronize". Os jogos da Epic, GOG e outros aparecem dentro da biblioteca do Steam, com capas.
4. Volte para o Gaming Mode. Tudo fica numa interface so.

## Testando em maquina virtual

O Gaming Mode precisa de aceleracao de GPU real e normalmente nao funciona bem em VirtualBox ou VMware (tela preta). Para ver de verdade, use um pendrive ou um SSD sobrando. A imagem qcow2 funciona no virt-manager/QEMU para checar o sistema, mas nao representa o desempenho real.

## Assinatura (opcional)

O passo de assinatura da imagem esta configurado para nao travar o build. Se quiser assinar, gere a chave com `COSIGN_PASSWORD="" cosign generate-key-pair`, salve o conteudo de `cosign.key` como secret `SIGNING_SECRET` no repositorio e faca commit do `cosign.pub`. Nunca envie o `cosign.key` para o GitHub.
