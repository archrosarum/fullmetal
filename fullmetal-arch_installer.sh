#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # #
# INSTALLER SHELL SCRIPT FOR FULLMETAL-ARCH #
#                                           #
# VERSION TO INSTALL:              MK-III_I #
# # # # # # # # # # # # # # # # # # # # # # #


cd "$(dirname "$0")" || exit


# CONSENT FROM THE USER (NO MEANS NO) #

echo "* BE WARNED that this script will erase its parent directory as a cleanup procedure. Only execute it from within the cloned repository."
read -p "* Input your understanding of this (y/N): " CONFIRMATION
if [[ "${CONFIRMATION,,}" == "y" ]]; then
    sleep 0.5
else
    echo "* Aborting installation script."
    exit
fi


# ENSURE DEPENDENCIES # 

echo "* Ensuring all dependencies..."

PACKAGES=("hyprland" "rofi" "mpvpaper" "grim" "kitty" "unzip" "ffmpeg" "sublime-text-4" "zen-browser")
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


# ENSURE DIRECTORIES #

mkdir -p ~/screenshots

mkdir -p ~/wallpapers
mkdir -p ~/wallpapers/animated
mkdir -p ~/wallpapers/static


# COPY FILES INTO THEIR EXPECTED DIRECTORIES

mv ./animated-wallpapers/snow-fall_1080.mp4 ~/wallpapers/animated/snow-fall_1080.mp4

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


# DESTROY CLONED REPOSITORY

rm -r  "$(dirname "$0")"

