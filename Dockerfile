FROM php:7.2-fpm-stretch

RUN apt-get update \
    && apt-get install -y \
    libpng-dev \
    libicu-dev \
    libxmlrpc-core-c3-dev \
    libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install bcmath gd intl pdo_mysql soap hash opcache xsl zip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN find "$PHP_INI_DIR" -name php.ini -exec sed -i 's/memory_limit.*/memory_limit = -1/g' {} \;

RUN groupadd web -g 1212
RUN useradd -m -u 1212 -g web -s /bin/bash magento
USER magento
