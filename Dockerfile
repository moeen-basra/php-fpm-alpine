FROM php:8.1-fpm-alpine

ARG xdebug=true
ARG xdebug_remote_host=docker.for.mac.localhost
ARG xdebug_port=9001

ENV XDEBUG=$xdebug
ENV XDEBUG_REMOTE_HOST=$xdebug_remote_host
ENV XDEBUG_PORT=$xdebug_port

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh