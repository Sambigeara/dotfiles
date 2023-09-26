#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# nvim
ln -sfn $DOTFILES_DIR/nvim ~/.config/nvim

# alacritty
ln -sfn $DOTFILES_DIR/alacritty ~/.config/alacritty

# fish
ln -sfn $DOTFILES_DIR/fish ~/.config/fish

# tmux
ln -sf $DOTFILES_DIR/tmux/.tmux.conf ~/.tmux.conf

git submodule update --init --recursive

echo "Symlinks created."
