#!/usr/bin/env bash

echo "Install apt modules"
sudo apt install -y curl git

echo "Instal asdf"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

echo "Update Oh my zsh plugins"
sed -i -e 's/^\(plugins=(.*\))$/\1 asdf)/' ~/.zshrc

zsh <<UPDATE
    asdf update
UPDATE

