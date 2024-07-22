#!/usr/bin/env bash

set -e
set -x

tmpDir=$(mktemp -d)
id=$(id -u)
gid=$(id -g)
sudoCmd=""

if [[ ! -z $CLIENT_ID ]]; then
    echo "[blackfire]" > $HOME/.blackfire.ini
    echo "client-id=$CLIENT_ID" >> $HOME/.blackfire.ini
    echo "client-token=$CLIENT_TOKEN" >> $HOME/.blackfire.ini

    # iterate over all folders in /home
    for d in /home/*; do
        if [ -d "$d" ]; then
            # get the username of the folder
            username=$(basename $d)
            # create the .blackfire.ini file in the user's home directory
            cp $HOME/.blackfire.ini $d
            chown $username:$username $d/.blackfire.ini
        fi
    done
fi

if ! command -v curl &> /dev/null; then
    echo "Installing curl"

    if command -v apk &> /dev/null; then
        apk add --no-cache curl
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y curl
    fi
fi

cd $tmpDir

curl -L -s https://blackfire.io/api/v1/releases/cli/linux/$(uname -m) -o blackfire-cli.tar.gz
tar zxpf blackfire-cli.tar.gz

mv ./blackfire /usr/bin/blackfire
mkdir -p /var/run/blackfire/
chmod -R 777 /var/run/blackfire/

if [[ ! -z $SERVER_ID ]]; then
    mkdir -p /etc/blackfire

    echo "[blackfire]" > agent
    echo "server-id=$SERVER_ID" >> agent
    echo "server-token=$SERVER_TOKEN" >> agent
    mv agent /etc/blackfire/agent

    if [[ -e /etc/Procfile ]]; then
        echo "blackfire-agent: /usr/bin/blackfire agent" >> /etc/Procfile
    fi
fi

if command -v php &> /dev/null; then
    $sudoCmd blackfire php:install
fi

