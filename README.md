# This is development - php

Base php docker image 

This image contains:
- docker-user-init (https://github.com/thisisdevelopment/docker-user-init) 
- nginx:stable
- composer:latest
- node:lts (for webpack builds etc)
- php-fpm:7.X with the following extra extensions enabled
  - amqp 
  - bcmath
  - bz2 
  - calendar
  - exif
  - gd
  - gettext
  - imagick
  - intl 
  - mysqli
  - opcache
  - pcntl
  - pdo_mysql
  - redis
  - soap
  - sockets
  - tidy
  - xsl
  - yaml
  - zip
  - xdebug (available, but not enabled)

  