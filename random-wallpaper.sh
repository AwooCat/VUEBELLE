#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/walls"
MONITOR="eDP-1"

WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
