FROM php:fpm-alpine

# Build Arguments
ARG user=laravel
ARG uid=1000
ARG xdebug=true
ARG xdebug_remote_host=docker.for.mac.localhost
ARG xdebug_port=9001

# Set Build Environment Variables
ENV USER=${user}
ENV XDEBUG=${xdebug}
ENV XDEBUG_REMOTE_HOST=${xdebug_remote_host}
ENV XDEBUG_PORT=${xdebug_port}

# ADD and set Group
RUN addgroup -g $uid $user && adduser -G $user -g $user -s /bin/sh -D $user

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh