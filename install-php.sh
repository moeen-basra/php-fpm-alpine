#!/bin/sh

apk add --update --no-cache $PHPIZE_DEPS \
    bzip2-dev freetype-dev icu-dev jpeg-dev libjpeg-turbo-dev libmemcached-dev libpng-dev libxml2-dev libzip-dev openldap-dev postgresql-dev \
    freetype \
    libpng \
    libjpeg-turbo \
    zip

# Install icu-libs separately to ensure it's available at runtime
apk add --no-cache icu-libs

docker-php-ext-configure gd --with-freetype --with-jpeg &&
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) &&
    docker-php-ext-install -j${NPROC} gd &&
    docker-php-ext-install bcmath bz2 intl ldap pcntl pdo_mysql pdo_pgsql soap sockets xml zip

# Install php pickle replacement for pecl
curl -sSLo /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar
chmod +x /usr/local/bin/pickle
pickle install -n --defaults igbinary
pickle install -n --defaults memcached
pickle install -n --defaults redis
pickle install -n --defaults xmlrpc

docker-php-ext-enable igbinary memcached redis xmlrpc >/dev/null

if [ $XDEBUG ]; then
    pickle install -n --defaults xdebug
    docker-php-ext-enable xdebug >/dev/null
    echo "remote_host=${XDEBUG_REMOTE_HOST}
remote_port=${XDEBUG_PORT}
remote_enable=1
idekey=IDE_DEBUG
error_reporting=E_ALL
display_startup_errors=On
display_errors=On" >>/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Install composer
curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Install php unit
curl -sSL -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/bin/phpunit

# Create helper script to fix ICU version after apk upgrade
# The intl extension requires ICU 74, but apk upgrade may install ICU 76
cat > /usr/local/bin/fix-icu-version.sh << 'EOF'
#!/bin/sh
# Fix ICU version to 74.2-r1 to match intl extension requirements
# This script should be run after apk upgrade if edge repositories are used
set -e
echo "Fixing ICU version to 74.2-r1 for intl extension compatibility..."
apk del --force-broken-world icu-libs icu-data icu-data-en 2>/dev/null || true
apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/v3.21/main icu-libs=74.2-r1 icu-data=74.2-r1 icu-data-en=74.2-r1 || \
apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/v3.20/main icu-libs=74.2-r1 icu-data=74.2-r1 icu-data-en=74.2-r1 || \
apk add --no-cache icu-libs=74.2-r1 icu-data=74.2-r1 icu-data-en=74.2-r1
apk add --no-cache --force-overwrite icu-dev 2>/dev/null || true
ldconfig
echo "ICU version fixed successfully"
EOF
chmod +x /usr/local/bin/fix-icu-version.sh

# Clean up build dependencies if TMP is set, otherwise skip
if [ -n "$TMP" ]; then
    apk del $TMP
fi

# # Set timezone
# #RUN echo Asia/Karachi > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
