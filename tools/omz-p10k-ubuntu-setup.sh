#!/usr/bin/env bash

echo "Installing zsh"
sudo apt update && sudo apt install -y zsh git

sh -c zsh <<END

    echo "Install Oh My Zsh"
    echo -e "Y" | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo "Install powerlevel10k"
    git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    sed -i -e 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i -e 's/^plugins=.*$/plugins=( git zsh-syntax-highlighting zsh-autosuggestions )/' ~/.zshrc
END


