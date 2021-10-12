#!/bin/bash

# Variables
VM_USER=$1
AZP_URL=$2
AZP_TOKEN=$3
AZP_POOL=$4

set -e

if [ -z "$VM_USER" ]; then
  echo 1>&2 "error: missing AZP_URL environment variable"
  exit 1
else
  echo "Virtual Machine Admin User: $VM_USER" | tee /dev/stderr 
fi
 
if [ -z "$AZP_URL" ]; then
  echo 1>&2 "error: missing AZP_URL environment variable"
  exit 1
else
  echo "Azure DevOps URL: $AZP_URL" | tee /dev/stderr 
fi

if [ -z "$AZP_TOKEN" ]; then
  echo 1>&2 "error: missing AZP_TOKEN environment variable"
  exit 1
fi

if [ -z "$AZP_POOL" ]; then
  echo "Azure DevOps PAT: Default"
else
  echo "Azure DevOps PAT: $AZP_POOL" | tee /dev/stderr 
fi

if [ -n "$AZP_WORK" ]; then
  mkdir -p "$AZP_WORK"
fi

export AGENT_ALLOW_RUNASROOT="1"

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
export DEBIAN_FRONTEND=noninteractive
echo "APT::Get::Assume-Yes \"true\";" | sudo tee /etc/apt/apt.conf.d/90assumeyes

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Install software
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt-get install -y -qq \
  rpm \
  lsb-release \
  ca-certificates \
  curl \
  jq \
  git \
  iputils-ping \
  libcurl4 \
  libicu60 \
  libunwind8 \
  netcat \
  zip \
  unzip \
  wget \
  apt-transport-https \
  gnupg \
  gnupg-agent \
  apt-utils \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io

# Setup docker. For more information, see https://docs.docker.com/engine/install/linux-postinstall/
sudo usermod -aG docker $VM_USER
printf "{\"data-root\": \"/datadrive/docker\"}" | sudo tee -a /etc/docker/daemon.json

# Install Docker Compose. For more information, see https://docs.docker.com/compose/install/
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Aqua Trivy
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
# echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
# sudo apt-get install -y trivy

sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.19.2/trivy_0.19.2_Linux-64bit.deb
sudo dpkg -i trivy_0.19.2_Linux-64bit.deb

# Install kubectl (latest)
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl

# Install helm v3 (latest)
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 &&
  chmod 700 get_helm.sh &&
  ./get_helm.sh

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

cleanup() {
  if [ -e config.sh ]; then
    print_header "Cleanup. Removing Azure Pipelines agent..."

    ./config.sh remove --unattended \
      --auth PAT \
      --token $AZP_TOKEN
  fi
}

print_header() {
  lightcyan='\033[1;36m'
  nocolor='\033[0m'
  echo -e "${lightcyan}$1${nocolor}"
}

run_agent() {
  # Create run-agent.sh
  if [ ! -f ./run-agent.sh ]; then
    echo "./run-agent.sh file does not exist. Creating run-agent.sh..."
    # `exec` the node runtime so it's aware of TERM and INT signals
    # AgentService.js understands how to handle agent self-update and restart
    printf 'exec ./externals/node/bin/node ./bin/AgentService.js interactive\n' >>./run-agent.sh
    chmod 777 ./run-agent.sh
  else
    echo "./run-agent.sh file already exists."
  fi

  # Schedule run-agent.sh execution to avoid a blocking call
  at now + 1 minute -f ./run-agent.sh
}

# Let the agent ignore the token env variables
export VSO_AGENT_IGNORE=AZP_TOKEN

print_header "1. Determining matching Azure Pipelines agent..."

AZP_AGENT_RESPONSE=$(curl -LsS \
  -u user:$AZP_TOKEN \
  -H 'Accept:application/json;api-version=3.0-preview' \
  "$AZP_URL/_apis/distributedtask/packages/agent?platform=linux-x64")

if echo "$AZP_AGENT_RESPONSE" | jq . >/dev/null 2>&1; then
  AZP_AGENTPACKAGE_URL=$(echo "$AZP_AGENT_RESPONSE" |
    jq -r '.value | map([.version.major,.version.minor,.version.patch,.downloadUrl]) | sort | .[length-1] | .[3]')
fi

echo "AZP_AGENT_RESPONSE: $AZP_AGENT_RESPONSE" | tee /dev/stderr 
echo "AZP_AGENTPACKAGE_URL: $AZP_AGENTPACKAGE_URL" | tee /dev/stderr 

if [ -z "$AZP_AGENTPACKAGE_URL" -o "$AZP_AGENTPACKAGE_URL" == "null" ]; then
  echo 1>&2 "error: could not determine a matching Azure Pipelines agent - check that account '$AZP_URL' is correct and the token is valid for that account"
  exit 1
fi

print_header "2. Downloading and installing Azure Pipelines agent..."

curl -LsS $AZP_AGENTPACKAGE_URL | tar -xz &
wait $!

source ./env.sh

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

print_header "3. Configuring Azure Pipelines agent..."

./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "$AZP_URL" \
  --auth PAT \
  --token "$AZP_TOKEN" \
  --pool "${AZP_POOL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace \
  --acceptTeeEula &
wait $!

print_header "4. Running Azure Pipelines agent..."

run_agent
