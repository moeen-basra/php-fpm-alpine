# Use ARGs for PHP and Alpine versions
ARG php_version=8.2
ARG alpine_version=3.18

# Use the chosen versions for the FROM statement
FROM php:${php_version}-fpm-alpine${alpine_version}

# Set ARGs for xdebug
ARG xdebug=false
ARG xdebug_host=host.docker.internal
ARG xdebug_idekey=IDE_DEBUG
ARG xdebug_port=9003
ARG xdebug_version=3.2.2

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh --xdebug=$xdebug --xdebug-version=$xdebug_version --xdebug-host=$xdebug_host --xdebug-port=$xdebug_port --xdebug-idekey=$xdebug_idekey
