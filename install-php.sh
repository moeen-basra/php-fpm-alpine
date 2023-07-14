#!/bin/sh

# Parse script arguments
while [ $# -gt 0 ]; do
    case "$1" in
    --xdebug=*)
        xdebug="${1#*=}"
        ;;
    --xdebug-remote-host=*)
        xdebug_remote_host="${1#*=}"
        ;;
    --xdebug-port=*)
        xdebug_port="${1#*=}"
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
    linux-headers

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
pickle install -n --defaults xdebug
docker-php-ext-enable igbinary memcached redis xmlrpc >/dev/null

# Install Xdebug if enabled
if [ "$xdebug" = true ]; then
    docker-php-ext-enable xdebug >/dev/null
    echo "remote_host=${xdebug_remote_host}
remote_port=${xdebug_port}
remote_enable=1
idekey=IDE_DEBUG
error_reporting=E_ALL
display_startup_errors=On
display_errors=On" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Install Composer
curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit
curl -sSL -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/bin/phpunit

# Remove temporary packages
apk del $PHPIZE_DEPS

# Set timezone (optional)
# echo "Asia/Karachi" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
