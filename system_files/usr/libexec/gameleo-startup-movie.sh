#!/bin/bash
# Coloca o video de abertura do GameLeoBeStation no Steam (roda a cada login do usuario).
# So age depois que o Steam ja foi configurado pela primeira vez.
STEAM="$HOME/.local/share/Steam"
[ -f "$STEAM/steam.sh" ] || exit 0
DEST="$STEAM/config/uioverrides/movies"
mkdir -p "$DEST"
cmp -s /usr/share/gameleobestation/deck_startup.webm "$DEST/deck_startup.webm" || \
    cp -f /usr/share/gameleobestation/deck_startup.webm "$DEST/deck_startup.webm"
