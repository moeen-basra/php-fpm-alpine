FROM php:8.2-fpm-alpine

ARG xdebug=${xdebug:-false}
ARG xdebug_host=${xdebug_host:-host.docker.internal}
ARG xdebug_port=${xdebug_port:-9003}

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh --xdebug=$xdebug --xdebug-host=$xdebug_host --xdebug-port=$xdebug_port
