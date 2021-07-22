#!/usr/bin/env bash

echo "Installing apt libraries"
sudo apt update && sudo apt install -y zsh git wget curl

echo "##############################################"
echo "Install Oh My Zsh"
echo "##############################################"
echo -e "Y" | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" <<INSTALL
    exit
INSTALL

zsh <<UTILS
    echo "##############################################"
    echo "Install powerlevel10k"
    echo "##############################################"
    git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    sed -i -e 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i -e 's/^plugins=.*$/plugins=( git zsh-syntax-highlighting zsh-autosuggestions )/' ~/.zshrc
UTILS

echo "##############################################"
echo "Download fontfiles"
echo "##############################################"
sudo mkdir -p /mnt/c/temp/
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P /mnt/c/temp/
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -P /mnt/c/temp/
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -P /mnt/c/temp/
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -P /mnt/c/temp/
echo "##############################################"
echo "!!!!To be able to use icons on your terminal, these font files need to be installed manually"
echo "##############################################"

echo "##############################################"
echo "Updating runcom files"
echo "##############################################"
echo "\ncd ~" >> ~/.bashrc
echo "\nbash -c zsh" >> ~/.bashrc

echo "##############################################"
echo "!!!!Please open a new terminal session to finish the setup"
echo "##############################################"