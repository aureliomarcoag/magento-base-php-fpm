FROM php:7.2-fpm-alpine3.8

RUN php -i

# Already compiled with php:
# php -i | egrep -io 'bcmath|bz2|ctype|curl|dom|gd|iconv|intl|json|mbstring|pdo_mysql|soap|xmlrpc|zip|bash|spl|openssl' | tr '[[:upper:]]' '[[:lower:]]' | sort | uniq | tr $'\n' ' '
# bz2 ctype curl dom iconv json mbstring openssl spl xmlrpc zip

# simplexml

RUN apk add \
    libpng-dev \
    icu-dev \
    xmlrpc-c-dev \
    && docker-php-ext-install bcmath gd intl pdo_mysql soap hash opcache

RUN docker-php-ext-install opcache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"
