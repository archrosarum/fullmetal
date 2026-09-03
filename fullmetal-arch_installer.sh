#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # #
# INSTALLER SHELL SCRIPT FOR FULLMETAL-ARCH #
#                                           #
# VERSION TO INSTALL:                MK-III #
# # # # # # # # # # # # # # # # # # # # # # #


cd "$(dirname "$0")" || exit


echo "* Ensuring all dependencies..."

PACKAGES=("hyprland" "rofi" "mpvpaper" "grim" "kitty")
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "You must install yay to run this installer."
    exit
fi

for PKG in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$PKG" &> /dev/null; then
        echo "* $PKG is not installed. Installing now..."
        yay -S --noconfirm "$PKG"
    else
        echo "* $PKG is already installed."
    fi
done


mkdir -p ~/screenshots

mkdir -p ~/wallpapers
mkdir -p ~/wallpapers/animated
mkdir -p ~/wallpapers/static


cp -r ./animated-wallpapers/* ~/wallpapers/animated/

if [ -d "$HOME/.config/hypr" ]; then
    mv "$HOME/.config/hypr" "$HOME/.config/hypr_backup"
fi
mkdir -p ~/.config/hypr && cp -r ./source-code/hyprland-configs/* ~/.config/hypr/

if [ -d "$HOME/.config/rofi" ]; then
    mv "$HOME/.config/rofi" "$HOME/.config/rofi_backup"
fi
mkdir -p ~/.config/rofi && cp -r ./source-code/rofi-configs/* ~/.config/rofi/

if [ -d "$HOME/.config/kitty" ]; then
    mv "$HOME/.config/kitty" "$HOME/.config/kitty_backup"
fi
mkdir -p ~/.config/kitty && cp -r ./source-code/kitty-configs/* ~/.config/kitty/
