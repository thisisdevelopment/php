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
  - grpc
  - imagick
  - intl 
  - mysqli
  - opcache
  - pcntl
  - pdo_mysql
  - protobuf
  - redis
  - soap
  - sockets
  - tidy
  - xsl
  - yaml
  - zip
  - xdebug (available, but not enabled)
- with the following utils installed
  - lsof
  - unzip
  - mysql-client
  - nano + joe + vim 
  - git
  - protoc + grpc language plugins
  