#!/usr/bin/env bash

set -e

# check curl is installed and install it if missing
if ! command -v curl &> /dev/null
then
    apt-get update
    apt-get install -y curl
fi

curl https://github.com/FriendsOfShopware/shopware-cli/releases/latest/download/shopware-cli_Linux_x86_64.tar.gz -L -o cli.tar.gz

mkdir /tmp/sw-cli
tar -xzf cli.tar.gz -C /tmp/sw-cli

mv /tmp/sw-cli/shopware-cli /usr/local/bin/shopware-cli

if [[ -d /etc/bash_completion.d ]]; then
    shopware-cli completion bash | tee /etc/bash_completion.d/shopware-cli
fi

if [[ -d /usr/local/share/zsh/site-functions ]]; then
    shopware-cli completion zsh | tee /usr/local/share/zsh/site-functions/_shopware-cli
fi

if [[ -d /usr/share/fish/completions ]]; then
    shopware-cli completion fish | tee /usr/share/fish/completions/shopware-cli.fish
fi

rm -rf /tmp/sw-cli
rm cli.tar.gz
