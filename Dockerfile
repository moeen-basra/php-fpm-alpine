FROM php:8.1.8-fpm-alpine3.16

# Set Build Environment Variables
ENV USER=${user:-laravel}
ENV GID=${gid:-1000}
ENV XDEBUG=${xdebug:-true}
ENV XDEBUG_REMOTE_HOST=${xdebug_remote_host:-docker.for.mac.localhost}
ENV XDEBUG_PORT=${xdebug_port:-9001}

# ADD and set Group
RUN addgroup -g $GID $USER && adduser -G $USER -g $USER -s /bin/sh -D $USER

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh