ARG LARADOCK_UID=1000
ARG LARADOCK_GID=1000
ARG LARADOCK_ENVIRONMENT=production
ARG LARADOCK_APP_PATH=.
ARG LARADOCK_PHP_VERSION=""

FROM php:${LARADOCK_PHP_VERSION:+${LARADOCK_PHP_VERSION}-}fpm-alpine AS base

ARG LARADOCK_PHP_VERSION

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
    if [ -z "$LARADOCK_PHP_VERSION" ] ||                                \
    [ "$(echo ${LARADOCK_PHP_VERSION} | cut -d '.' -f1)" -gt 7 ] ||     \
    ([ "$(echo ${LARADOCK_PHP_VERSION} | cut -d '.' -f1)" -eq 7 ]    && \
    [ "$(echo ${LARADOCK_PHP_VERSION} | cut -d '.' -f2)" -ge 4 ]); then \
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

WORKDIR /tmp/_scripts
COPY ./compose/app/scripts/* ./
RUN \
    if [ -f "./base.sh" ]; then \
        chmod +x "./base.sh" && \
        ./base.sh;              \
    fi

FROM base AS base_composer

ARG LARADOCK_ENVIRONMENT
ARG LARADOCK_APP_PATH

WORKDIR /var/www/html
COPY ${LARADOCK_APP_PATH} .
RUN \
    if [ "${LARADOCK_ENVIRONMENT}" = "development" ]; then \
        composer install        \
            --no-ansi           \
            --no-interaction    \
            --no-progress       \
            --prefer-dist;      \
    else \
        composer install            \
            --no-ansi               \
            --no-cache              \
            --no-dev                \
            --no-interaction        \
            --no-plugins            \
            --no-progress           \
            --no-scripts            \
            --optimize-autoloader   \
            --prefer-dist;          \
    fi

WORKDIR /var/www/html/_scripts
COPY ./compose/app/scripts/* ./
RUN \
    if [ -f "./composer.sh" ]; then \
        chmod +x "./composer.sh" && \
        ./composer.sh;              \
    fi

FROM base AS app

ARG LARADOCK_UID
ARG LARADOCK_GID
ARG LARADOCK_ENVIRONMENT
ARG LARADOCK_APP_PATH

WORKDIR /var/www/html
RUN \
    addgroup -g ${LARADOCK_GID} laradock && \
    adduser -u ${LARADOCK_UID} -G laradock -D laradock

COPY --chown=laradock:laradock                          ${LARADOCK_APP_PATH}    .
COPY --chown=laradock:laradock  --from=base_composer    /var/www/html/vendor    ./vendor

WORKDIR /var/www/html
COPY ./compose/app/php/* ./_php/
RUN \
    mv  ./_php/www.conf     /usr/local/etc/php-fpm.d/www.conf       && \
    mv  ./_php/opcache.ini  /usr/local/etc/php/conf.d/opcache.ini   && \
    if [ "${LARADOCK_ENVIRONMENT}" = "development" ]; then          \
        mv  ./_php/php.development.ini  /usr/local/etc/php/php.ini; \
    else  \
        mv  ./_php/php.production.ini   /usr/local/etc/php/php.ini; \
    fi && \
    rm -rf ./_php

WORKDIR /var/www/html/_scripts
COPY ./compose/app/scripts/* ./
RUN \
    if [ -f "./app.sh" ]; then  \
        chmod +x "./app.sh"  && \
        ./app.sh;               \
    fi

WORKDIR /var/www/html
RUN \
    chown -R laradock:laradock /var/www/html    && \
    chmod -R 775 /var/www/html                  && \
    rm  -rf                 \
        /tmp/*              \
        /usr/includes/*     \
        /usr/share/man/*    \
        /var/cache/apk/*    \
        /var/tmp/*          \
        /var/www/html/_scripts

USER laradock:laradock

CMD ["php-fpm"]