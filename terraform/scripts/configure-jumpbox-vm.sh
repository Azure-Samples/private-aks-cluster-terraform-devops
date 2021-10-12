#!/bin/bash

# Eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Install kubectl (latest)
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl

# Install helm v3 (latest)
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 &&
  chmod 700 get_helm.sh &&
  ./get_helm.sh

# Install Azure CLI (latest)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash