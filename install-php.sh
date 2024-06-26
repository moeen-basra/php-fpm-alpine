#!/bin/sh

# Parse script arguments
while [ $# -gt 0 ]; do
    case "$1" in
    --xdebug=*)
        xdebug="${1#*=}"
        ;;
    --xdebug-version=*)
        xdebug_version="${1#*=}"
        ;;
    --xdebug-host=*)
        xdebug_host="${1#*=}"
        ;;
    --xdebug-port=*)
        xdebug_port="${1#*=}"
        ;;
    --xdebug-idekey=*)
        xdebug_idekey="${1#*=}"
        ;;
    *)
        echo "Error: Invalid argument: $1"
        exit 1
        ;;
    esac
    shift
done

# Check if PHPIZE_DEPS is set
if [ -z "$PHPIZE_DEPS" ]; then
    echo "Error: PHPIZE_DEPS variable is not set."
    exit 1
fi

# Update package repositories
apk update

# Install required packages
apk add --update --no-cache \
    $PHPIZE_DEPS \
    bzip2-dev \
    freetype-dev \
    icu-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    libmemcached-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    openldap-dev \
    postgresql-dev \
    freetype \
    libpng \
    libjpeg-turbo \
    zip \
    linux-headers \
    supervisor \
    git \
    nano \
    nodejs \
    npm \
    postgresql-client

# Configure and install gd extension
docker-php-ext-configure gd --with-freetype --with-jpeg
NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)
docker-php-ext-install -j${NPROC} gd

# Install other required extensions
docker-php-ext-install bcmath bz2 intl ldap pcntl pdo_mysql pdo_pgsql soap sockets xml zip

# Install php pickle replacement for pecl
curl -sSLo /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar
chmod +x /usr/local/bin/pickle
pickle install -n --defaults igbinary
pickle install -n --defaults memcached
pickle install -n --defaults redis
pickle install -n --defaults xmlrpc
pickle install -n --defaults xdebug@${xdebug_version}
docker-php-ext-enable igbinary memcached redis xmlrpc xdebug >/dev/null

# Install Xdebug if enabled
if [ "$xdebug" = true ]; then
    docker-php-ext-enable xdebug >/dev/null
    echo -e "xdebug.client_host=${xdebug_host}" \
        "\nxdebug.client_port=${xdebug_port}" \
        "\nxdebug.mode=develop,coverage,debug,trace" \
        "\nxdebug.start_with_request=yes" \
        "\nxdebug.idekey=${xdebug_idekey}" \
        >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Install Composer
curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit
curl -sSL -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/bin/phpunit

# Remove temporary packages
apk del $PHPIZE_DEPS

rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
