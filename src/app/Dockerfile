ARG MAIN_DIRECTORY=".laradock"
ARG MAIN_UID="1000"
ARG MAIN_GID="1000"
ARG MAIN_PHP_VERSION=""

FROM php:${MAIN_PHP_VERSION:+${MAIN_PHP_VERSION}-}fpm-alpine AS base

ARG MAIN_DIRECTORY
ARG MAIN_PHP_VERSION

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

WORKDIR /tmp

RUN \
    apk update && apk --no-cache add \
        curl                \
        freetype-dev        \
        libjpeg-turbo-dev   \
        libzip-dev          \
        oniguruma-dev       \
        && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j "$(nproc)" \
        bcmath      \
        mbstring    \
        opcache     \
        pdo_mysql   \
        zip

WORKDIR /tmp
RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /tmp
RUN \
    # https://www.php.net/manual/en/image.installation.php
    if [ -z "$MAIN_PHP_VERSION" ] ||                                    \
    [  "$(echo ${MAIN_PHP_VERSION} | cut -d '.' -f1)" -gt 7 ] ||        \
    ([ "$(echo ${MAIN_PHP_VERSION} | cut -d '.' -f1)" -eq 7 ] &&        \
    [  "$(echo ${MAIN_PHP_VERSION} | cut -d '.' -f2)" -ge 4 ]); then    \
        docker-php-ext-configure gd \
            --with-freetype         \
            --with-jpeg;            \
    else \
        apk --no-cache add libpng-dev        && \
        docker-php-ext-configure gd             \
            --with-gd                           \
            --with-freetype-dir=/usr/include    \
            --with-jpeg-dir=/usr/include        \
            --with-png-dir=/usr/include;        \
    fi && \
    docker-php-ext-install -j "$(nproc)" gd

WORKDIR /tmp
COPY ./${MAIN_DIRECTORY}/app/scripts/* ./
RUN \
    if [ -f "./base.sh" ]; then \
        chmod +x "./base.sh" && \
        ./base.sh;              \
    fi

FROM base AS app

ARG MAIN_DIRECTORY
ARG MAIN_UID
ARG MAIN_GID

WORKDIR /var/www/html
RUN \
    addgroup -g ${MAIN_GID} laradock && \
    adduser -u ${MAIN_UID} -G laradock -D laradock

COPY --chown=laradock:laradock .. .

WORKDIR /var/www/html/${MAIN_DIRECTORY}/app/php
RUN \
    cp  ./www.conf      /usr/local/etc/php-fpm.d/   && \
    cp  ./opcache.ini   /usr/local/etc/php/conf.d/  && \
    cp  ./php.ini       /usr/local/etc/php/

WORKDIR /var/www/html
COPY ./${MAIN_DIRECTORY}/app/scripts/* ./
RUN \
    if [ -f "./app.sh" ]; then  \
        chmod +x "./app.sh"  && \
        ./app.sh;               \
    fi

WORKDIR /var/www/html
RUN \
    chown -R laradock:laradock /var/www/html    && \
    chmod -R 775 /var/www/html                  && \
    rm  -rf                         \
        /tmp/*                      \
        /usr/includes/*             \
        /usr/local/lib/php/doc/*    \
        /usr/share/doc/*            \
        /usr/share/info/*           \
        /usr/share/man/*            \
        /var/cache/apk/*            \
        /var/tmp/*

USER laradock:laradock

CMD ["php-fpm"]