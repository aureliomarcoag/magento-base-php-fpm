FROM php:7.2-fpm-stretch

# git and procps are required to run setup:dev:tests

RUN apt-get update --no-install-recommends \
    && apt-get install -y \
    libpng-dev \
    libicu-dev \
    libxmlrpc-core-c3-dev \
    libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    git \
    procps \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /etc/nginx \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install bcmath gd intl pdo_mysql soap hash opcache xsl zip \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && curl -s http://gordalina.github.io/cachetool/downloads/cachetool.phar -o /usr/local/bin/cachetool && chmod +x /usr/local/bin/cachetool \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && find "$PHP_INI_DIR" -name php.ini -exec sed -i 's/memory_limit.*/memory_limit = -1/g' {} \; \
    && rm /usr/local/etc/php-fpm.d/* -f \
    && rm -Rf /var/www \
    && groupadd web -g 1212 \
    && useradd -m -u 1212 -g web -s /bin/bash magento

COPY nginx /etc/nginx
COPY fpm.conf /usr/local/etc/php-fpm.d/
COPY magento /var/www
COPY entrypoint.sh /entrypoint.sh

CMD ["bash", "/entrypoint.sh"]
