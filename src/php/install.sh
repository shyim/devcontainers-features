#!/usr/bin/env bash

export DEBIAN_FRONTEND="noninteractive"

set -e
EXTENSIONS="bcmath bz2 curl gd gmp intl opcache pgsql mysql readline soap xml xsl zip sqlite"

if [[ "$DISABLEALLEXTENSIONS" == "true" ]]; then
    EXTENSIONS=""
fi

if [[ -n "$EXTENSIONSEXTRA" ]]; then
    EXTENSIONS="$EXTENSIONS,$EXTENSIONSEXTRA"
fi

EXTENSIONS="cgi,cli,fpm,phpdbg,$EXTENSIONS"

MODULES=(${EXTENSIONS//,/ })

OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
VERSION_CODENAME=$(awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release)

# Needed by composer
prerequisites=('unzip')

# Needed by php base
prerequisites+=('tzdata')

prerequisites+=('curl')

if [[ "$OS" == '"Ubuntu"' ]]; then
    apt-get update
    apt-get install -y gnupg ca-certificates

    if [[ "$VERSION_CODENAME" == "focal" ]]; then
        echo "Detected: Ubuntu Focal (20.04)"
        echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ondrej-php.list
    elif [[ "$VERSION_CODENAME" == "jammy" ]]; then
        echo "Detected: Ubuntu Jammy (22.04)"
        echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ondrej-php.list
    else
        echo "Detected: Ubuntu Noble (24.04)"
        echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ondrej-php.list
    fi

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
elif [[ "$OS" == '"Debian GNU/Linux"' ]]; then
    apt-get update
    apt-get -y install apt-transport-https lsb-release ca-certificates curl
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
fi

# loop over MODULES
for module in "${MODULES[@]}"
do
    prerequisites+=("php${VERSION}-${module}")
done

apt-get update

apt-get install --no-install-recommends -y "${prerequisites[@]}"

# Setup php session directory
mkdir -p /var/lib/php/sessions/
chown -R 1000:1000 /var/lib/php/sessions/

if [[ $INSTALLCOMPOSER == "true" ]]; then
    curl -sSLo composer-setup.php https://getcomposer.org/installer
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
fi

if [[ "${MODULES[@]}" =~ "xdebug" ]]; then
    XDEBUG_INI="/etc/php/${VERSION}/mods-available/xdebug.ini"

    echo "" >> "${XDEBUG_INI}"
    echo "xdebug.mode = debug" >> "${XDEBUG_INI}"
    echo "xdebug.client_port = 9003" >> "${XDEBUG_INI}"
fi
