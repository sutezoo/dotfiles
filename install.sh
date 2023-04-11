#!/usr/bin/env bash
set -ue

sudo apt update
sudo apt upgrade -y

# fish related installs
## fish
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish

## fisher
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install oh-my-fish/theme-bobthefish jethrokuan/fzf decors/fish-ghq jorgebucaran/nvm.fish"

## fzf
sudo apt install -y fzf

# base16-shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# ghq
sudo apt install -y build-essential
## golang(v1.20.3)
wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
/usr/local/go/bin/go install github.com/x-motemen/ghq@latest

# symbolic links
ln -snf $(pwd)/.bashrc ~/.bashrc
ln -snf $(pwd)/.tmux.conf ~/.tmux.conf
ln -snf $(pwd)/config.fish ~/.config/fish/config.fish
ln -snf $(pwd)/tminimum.fish ~/.config/fish/functions/tminimum.fish
