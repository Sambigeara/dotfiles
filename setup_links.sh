#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/alacritty" ~/.config/alacritty
ln -sfn "$DOTFILES_DIR/fish" ~/.config/fish
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
ln -sfn "$DOTFILES_DIR/skhd" ~/.config/skhd
ln -sfn "$DOTFILES_DIR/yabai" ~/.config/yabai
ln -sfn "$DOTFILES_DIR/aerospace" ~/.config/aerospace
ln -sfn "$DOTFILES_DIR/sketchybar" ~/.config/sketchybar
ln -sfn "$DOTFILES_DIR/ghostyy" ~/.config/ghostyy

git submodule update --init --recursive

echo "Symlinks created."
