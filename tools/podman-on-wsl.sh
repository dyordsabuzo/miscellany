#!/usr/bin/env sh

read -p "WARNING! This should be run only with ubuntu on WSL.  Do you want to proceed? (Y/N) " response

[ $response != "Y" ] && [ $response != "y" ] && \
    echo Installation cancelled && \
    exit 0

. /etc/os-release
echo "Updating debian repository"
sudo sh -c \
    "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key -O Release.key
sudo apt-key add - < Release.key

echo "Updating, upgrading and installing podman"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y podman