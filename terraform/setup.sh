#!/bin/bash

# Cria diretório de trabalho e indo para ele
PROD=$/home/ubuntu/prod
mkdir $PROD

cd $PROD

# Atualiza dependências padrões
sudo apt update -y && sudo apt upgrade -y

# Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona repositorio docker nos conteúdos acessíveis do Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instala dependências do docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Instala dependências do PSQL
sudo apt install postgresql postgresql-client -y
