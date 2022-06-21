ARG VERSION=7.4-fpm
ARG FLAVOUR=""

FROM node:lts${FLAVOUR} AS node_lts
FROM nginx:stable${FLAVOUR} AS nginx_stable
FROM composer:2.1 AS composer_stable
FROM thisisdevelopment/docker-user-init:latest${FLAVOUR} AS docker-user-init
FROM scratch AS overlay

COPY --from=docker-user-init /docker-user-init /usr/bin/
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
COPY --from=composer_stable /usr/bin/composer /usr/bin/composer
COPY --from=node_lts /usr/local /usr/local
COPY --from=node_lts /opt /opt
COPY --from=nginx_stable /usr/sbin/nginx* /usr/sbin/
COPY --from=nginx_stable /usr/lib/nginx /usr/lib/nginx
COPY --from=nginx_stable /etc/nginx /etc/nginx
COPY files /

FROM php:${VERSION}${FLAVOUR}
WORKDIR /var/www

ENV \
  PHP_EXTENSIONS="amqp bcmath bz2 calendar exif gd gettext grpc imagick intl mysqli opcache pcntl pdo_mysql protobuf redis soap sockets tidy xdebug xsl yaml zip" \
  EXTRA_PACKAGES="lsof unzip mysql-client nano joe vim git grpc" \
  DOCKER_USER="www-data:www-data" \
  COMPOSER_MEMORY_LIMIT="-1"

COPY --from=overlay / /

RUN set -eux; \
    chmod u+s,g+s /usr/bin/docker-user-init; \
    install-php-extensions ${PHP_EXTENSIONS}; \
    pkg-install runit libcap pcre shadow dumb-init bash ${EXTRA_PACKAGES}; \
    pkg-purge ${PHPIZE_DEPS}; \
    pkg-cleanup; \
    setcap cap_net_bind_service=+ep /usr/sbin/nginx; \
    rm -f $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini; \
    rm -f $PHP_INI_DIR/conf.d/docker-php-ext-protobuf.ini; \
    mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini; \
    mv /app.ini $PHP_INI_DIR/conf.d/app.ini; \
    rm -rf /var/www/*; \
    mkdir -p /home/www /var/log/nginx; \
    chown -R -h ${DOCKER_USER} /home/www /var/www /etc/service /var/log/nginx; \
    [ -f /sbin/runsvdir ] || ln -s /usr/bin/runsvdir /sbin/;

USER ${DOCKER_USER}
ENTRYPOINT ["/usr/bin/docker-user-init", "--"]
CMD ["/sbin/runsvdir", "-P", "/etc/service"]
