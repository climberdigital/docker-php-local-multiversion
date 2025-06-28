FROM php:8.2.28-fpm-alpine3.22

WORKDIR /home/dev/apps

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    addgroup -g 1000 dev && \
    adduser -u 1000 -G dev -h /home/dev -D dev && \
    sed -i "s/user = www-data/user = dev/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/group = www-data/group = dev/g" /usr/local/etc/php-fpm.d/www.conf && \
    echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf && \
    apk update && apk upgrade && \
    apk add --no-cache \
      bash \
      git \
      openssh \
      freetype \
      libjpeg-turbo \
      libpng \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      zip \
      libzip-dev && \
    docker-php-ext-install pdo pdo_mysql mysqli && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-enable gd && \
    docker-php-ext-configure zip && \
    docker-php-ext-install zip && \
    docker-php-ext-install exif && \
    apk add --no-cache pcre-dev ${PHPIZE_DEPS} && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

COPY --from=composer:2.8.8 /usr/bin/composer /usr/bin/composer

ADD ../../aliases.sh /etc/profile.d/aliases.sh

ADD ./php.ini /usr/local/etc/php/php.ini

USER dev

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
