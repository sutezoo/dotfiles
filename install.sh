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
set bashrc ~/.bashrc
set tmuxconf ~/.tmux.conf
set fishconf ~/.config/fish/config.fish
mkdir ~/backup
if [ -f bashrc ]; then
  mv $bashrc ~/backup
fi
if [ -f tmuxconf ]; then
  mv ~/.tmux.conf ~/backup
fi
if [ -f fishconf ]; then
  mv ~/.config/fish/config.fish ~/backup
fi

ln -s .bashrc ~/
ln -s .tmux.conf ~/
ln -s config.fish ~/.config/fish/
ln -s tminimum.fish ~/.config/fish/functions/
