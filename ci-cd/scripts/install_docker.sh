#!/bin/bash

set -euo pipefail

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo systemctl start docker
sudo systemctl enable docker

sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker "$USER"

# Verify Docker is running
sudo docker ps || (echo "Docker daemon not running" && exit 1)