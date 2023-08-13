#!/usr/bin/env bash

set -e

EXTENSIONS="bcmath bz2 calendar exif fileinfo ctype ftp gd gettext intl mysqli opcache mysqlnd pdo pdo_mysql xml curl dom ffi gmp igbinary pdo_sqlite pdo_pgsql posix sysvmsg sysvsem sysvshm tokenizer soap sockets xmlreader xmlwriter xsl pecl zip phar mbstring iconv simplexml sqlite3 sodium readline pgsql"

if [[ "$DISABLEALLEXTENSIONS" == "true" ]]; then
    EXTENSIONS=""
fi

if [[ -n "$EXTENSIONSEXTRA" ]]; then
    EXTENSIONS="$EXTENSIONS $EXTENSIONSEXTRA"
fi

disable_extensions() {
    ENABLED=" ${EXTENSIONS[*]} "

    for extension in /etc/php/$VERSION/cli/conf.d/*.ini; do
        FILENAME=$(basename $extension)
        NAME=$(basename $extension .ini | cut -c4-)

        if [[ ! "${ENABLED}" =~ " ${NAME} " ]]; then
            echo "Disabling PHP extension $NAME"
            rm -f "/etc/php/$VERSION/cli/conf.d/$FILENAME"
            rm -f "/etc/php/$VERSION/apache2/conf.d/$FILENAME"
            rm -f "/etc/php/$VERSION/cgi/conf.d/$FILENAME"
            rm -f "/etc/php/$VERSION/embed/conf.d/$FILENAME"
            rm -f "/etc/php/$VERSION/fpm/conf.d/$FILENAME"
            rm -f "/etc/php/$VERSION/phpdbg/conf.d/$FILENAME"
        fi
    done
}

OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
VERSION_CODENAME=$(awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release)

EXTENSIONS_ARRAY=("$EXTENSIONS")

# Needed by composer
prerequisites=('unzip')

# Needed by php base
prerequisites+=('libargon2-1')
prerequisites+=('tzdata')
prerequisites+=('libxml2')
prerequisites+=('libpcre2-8-0')

# Needed by php-fpm
prerequisites+=('libapparmor1')

for element in ${EXTENSIONS_ARRAY[@]};
do
    case $element in
        "amqp")
        prerequisites+=('librabbitmq4');;
        "curl")
        prerequisites+=('libcurl4');;
        "dba")
        prerequisites+=('liblmdb0' 'libqdbm14');;
        "odbc")
        prerequisites+=('libodbc1');;
        "enchant")
        prerequisites+=('libenchant-2-2');;
        "gd")
        prerequisites+=('libgd3');;
        "imagick")
        prerequisites+=('libgomp1' 'libmagickwand-6.q16-6' 'libmagickcore-6.q16-6');;
        "imap")
        prerequisites+=('libc-client2007e');;
        "memcached")
        prerequisites+=('libmemcached11');;
        "memcache")
        prerequisites+=('libmemcached11');;
        "pdo_firebird")
        prerequisites+=('libfbclient2');;
        "pdo_dblib")
        prerequisites+=('libsybdb5');;
        "pdo_sqlsrv")
        prerequisites+=('libodbcinst2');;
        "pdo_pgsql")
        prerequisites+=('libpq5');;
        "readline")
        prerequisites+=('libreadline8' 'libedit2');;
        "sodium")
        prerequisites+=('libsodium23');;
        "mbstring")
        prerequisites+=('libonig5');;
        "tidy")
        prerequisites+=('libtidy5deb1');;
        "xml")
        prerequisites+=('libxml2');;
        "xsl")
        prerequisites+=('libxslt1.1');;
        "yaml")
        prerequisites+=('libyaml-0-2');;
        "zip")
        prerequisites+=('libzip4');;
    esac
done

filename="debian10.tar.xz"

if [[ "$OS" == '"Ubuntu"' ]]; then
    apt-get update
    apt-get install -y gnupg ca-certificates

    if [[ "$VERSION_CODENAME" == "focal" ]]; then
        prerequisites+=('libssl1.1')
        filename="ubuntu20.04.tar.xz"
        echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ondrej-php.list
    else
        filename="ubuntu22.04.tar.xz"
        echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ondrej-php.list
    fi

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
elif [[ "$OS" == '"Debian GNU/Linux"' ]]; then
    apt-get update
    apt-get -y install apt-transport-https lsb-release ca-certificates curl
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

    if [[ "$VERSION_CODENAME" == "buster" ]]; then
        filename="debian10.tar.xz"
    elif [[ "$VERSION_CODENAME" == "bullseye" ]]; then
        filename="debian11.tar.xz"
    else
        filename="debian12.tar.xz"
    fi
fi

command -v wget >/dev/null || prerequisites+=('wget' 'ca-certificates')
command -v xz >/dev/null || prerequisites+=('xz-utils')
apt-get update

apt-get install --no-install-recommends -y "${prerequisites[@]}"

wget -q "https://github.com/shivammathur/php-builder/releases/download/${VERSION}/php_${VERSION}+${filename}" -O php.tar.xz

tar -xkf php.tar.xz -C /

disable_extensions

update-alternatives --install /usr/bin/php php "/usr/bin/php${VERSION}" 100
update-alternatives --install /usr/bin/php-config php-config "/usr/bin/php-config${VERSION}" 100
update-alternatives --install /usr/bin/phpize phpize "/usr/bin/phpize${VERSION}" 100
update-alternatives --install /usr/bin/php-cgi php-cgi "/usr/bin/php-cgi${VERSION}" 100
update-alternatives --install /usr/sbin/php-fpm php-fpm "/usr/sbin/php-fpm${VERSION}" 100

# Setup php session directory
mkdir -p /var/lib/php/sessions/
chown -R 1000:1000 /var/lib/php/sessions/

if [[ $INSTALLCOMPOSER == "true" ]]; then
    wget -q https://getcomposer.org/installer -O composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
fi
