#!/usr/bin/env bash
hyprlock &
swww init &
sleep 0.1 &&
swww img ~/.dotfiles/wallpaper/0.jpg &
nm-applet --indicator &
waybar &
swaync

