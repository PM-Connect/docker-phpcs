FROM php:7.2-alpine

ENV BUILD_DEPS="autoconf file g++ gcc libc-dev pkgconf re2c"
ENV LIB_DEPS="zlib-dev libzip-dev"
ENV TOOL_DEPS="git make unzip"
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN apk add --no-cache --virtual .tool-deps $TOOL_DEPS $LIB_DEPS \
 && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
 && docker-php-ext-install zip pcntl \
 && composer install \
 && git clone https://github.com/PM-Connect/PhpcsRulesets.git /rulesets \
 && /vendor/bin/phpcs --config-set installed_paths ../../slevomat/coding-standard,../../moxio/php-codesniffer-sniffs,/rulesets

CMD /vendor/bin/phpcs -n -s