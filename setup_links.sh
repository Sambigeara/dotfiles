#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/alacritty" ~/.config/alacritty
ln -sfn "$DOTFILES_DIR/fish" ~/.config/fish
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
ln -sfn "$DOTFILES_DIR/skhd" ~/.config/skhd
ln -sfn "$DOTFILES_DIR/yabai" ~/.config/yabai
ln -sfn "$DOTFILES_DIR/aerospace" ~/.config/aerospace
ln -sfn "$DOTFILES_DIR/ghostyy" ~/.config/ghostyy
ln -sfn "$DOTFILES_DIR/helix" ~/.config/helix
ln -sfn "$DOTFILES_DIR/rex" ~/.config/rex
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
ln -sfn "$DOTFILES_DIR/claude/hooks" ~/.claude/hooks

"$DOTFILES_DIR/helix/grammars/tree-sitter-git-blame/build.sh"

git submodule update --init --recursive

echo "Symlinks created."
