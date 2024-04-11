# Use the chosen versions for the FROM statement
FROM php:8.2-fpm-alpine

# Set ARGs for xdebug
ARG xdebug=false
ARG xdebug_host=host.docker.internal
ARG xdebug_idekey=IDE_DEBUG
ARG xdebug_port=9003
ARG xdebug_version=3.3.1

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh --xdebug=$xdebug --xdebug-version=$xdebug_version --xdebug-host=$xdebug_host --xdebug-port=$xdebug_port --xdebug-idekey=$xdebug_idekey
