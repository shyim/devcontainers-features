#!/usr/bin/env bash

set -e

# check curl is installed and install it if missing
if ! command -v curl &> /dev/null
then
    sudo apt-get install -y curl
fi

curl -sS https://get.symfony.com/cli/installer | sudo bash -s -- --install-dir=/usr/bin
