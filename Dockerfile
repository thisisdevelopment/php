ARG VERSION=7.4-fpm
ARG FLAVOUR=""

FROM node:lts${FLAVOUR} AS node_lts
FROM nginx:stable${FLAVOUR} AS nginx_stable
FROM thisisdevelopment/docker-user-init:latest${FLAVOUR} AS docker-user-init
FROM scratch AS overlay

COPY --from=docker-user-init /docker-user-init /usr/bin/
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=node_lts /usr/local /usr/local
COPY --from=node_lts /opt/yarn* /opt/
COPY --from=nginx_stable /usr/sbin/nginx* /usr/sbin/
COPY --from=nginx_stable /usr/lib/nginx /usr/lib/nginx
COPY --from=nginx_stable /etc/nginx /etc/nginx
COPY files /

FROM php:${VERSION}${FLAVOUR}
WORKDIR /var/www

ENV \
  PHP_EXTENSIONS="bcmath calendar exif gettext imagick intl mysqli opcache pcntl pdo_mysql redis soap sockets xdebug zip" \
  EXTRA_PACKAGES="unzip mysql-client nano joe vim" \
  DOCKER_USER="www-data:www-data"

COPY --from=overlay / /

RUN set -eux; \
    chmod u+s,g+s /usr/bin/docker-user-init; \
    install-php-extensions ${PHP_EXTENSIONS}; \
    pkg-install pcre shadow dumb-init bash ${EXTRA_PACKAGES}; \
    pkg-purge ${PHPIZE_DEPS}; \
    pkg-cleanup; \
    composer global require hirak/prestissimo; \
    cp -a /usr/local/etc/php/* /etc/php/; \
    rm -f /etc/php/conf.d/docker-php-ext-xdebug.ini; \
    mv /etc/php/php.ini-production /etc/php/php.ini; \
    rm -rf /var/www/*; \
    mkdir /home/www; \
    chown -R -h ${DOCKER_USER} /home/www /var/www;

USER ${DOCKER_USER}
ENTRYPOINT ["/usr/bin/docker-user-init", "--"]
CMD ["php-fpm"]
