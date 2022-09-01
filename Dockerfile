FROM php:8.1.8-fpm-alpine3.16

ARG user=forge
ARG gid=1000
ARG xdebug=true
ARG xdebug_remote_host=docker.for.mac.localhost
ARG xdebug_port=9001

# Set Build Environment Variables
ENV USER=$user
ENV XDEBUG=$xdebug
ENV XDEBUG_REMOTE_HOST=$xdebug_remote_host
ENV XDEBUG_PORT=$xdebug_port

# ADD and set Group
RUN addgroup -g $gid $USER && adduser -G $USER -g $USER -s /bin/sh -D $USER

# Install PHP extensions
ADD ./install-php.sh /usr/sbin/install-php.sh
RUN chmod +x /usr/sbin/install-php.sh \
    && /usr/sbin/install-php.sh