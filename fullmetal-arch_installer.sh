#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # #
# INSTALLER SHELL SCRIPT FOR FULLMETAL-ARCH #
#                                           #
# VERSION TO INSTALL:                MK-III #
# # # # # # # # # # # # # # # # # # # # # # #


cd "$(dirname "$0")" || exit


echo "* Ensuring all dependencies..."

PACKAGES=("hyprland" "rofi" "mpvpaper" "grim" "kitty")
sudo pacman -Sy

if ! command -v yay &> /dev/null; then
    echo "You must install yay to run this installer."
    exit

for PKG in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$PKG" &> /dev/null; then
        echo "* $PKG is not installed. Installing now..."
        yay -S --noconfirm "$PKG"
    else
        echo "* $PKG is already installed."
    fi
done


mkdir ~/screenshots

mkdir ~/wallpapers
mkdir ~/wallpapers/animated
mkdir ~/wallpapers/static


mv ~/.config/hypr ~/.config/hypr_backup
mkdir -p ~/.config/hypr && cp -r /source-code/hyprland-configs/* ~/.config/hypr/

mv ~/.config/rofi ~/.config/rofi_backup
mkdir -p ~/.config/rofi && cp -r /source-code/rofi-configs/* ~/.config/rofi/

mv ~/.config/kitty ~/.config/kitty_backup
mkdir -p ~/.config/kitty && cp -r /source-code/kitty-configs/* ~/.config/kitty/
