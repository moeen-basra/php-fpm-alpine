# Docker PHP FPM ALPINE

PHP FPM and ALPINE image for development.

## How to use

You can use this image using `moeenbasra/php-fpm-alpine:latest` or `moeenbasra/php-fpm-alpine:tag`

## Build the docker image using following command

`docker build moeenbasra/php-fpm-alpine:latest --build-arg user={user} gid={gid} xdebug={true|false} xdebug_remote_host={xdebug_remote_host} xdebug_port={xdebug_port}`

### Here is example

`docker build moeenbasra/php-fpm-alpine:latest --build-arg user=laravel gid=1000 xdebug=true xdebug_remote_host=docker.for.mac.localhost xdebug_port=9001`

You can also override some of deault build arguments

1. user // default laravel
2. gid // default 1000
3. xdebug // default true
4. xdebug_remote_host // default docker.for.mac.localhost
5. xdebug_port // default 9001
