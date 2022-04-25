FROM php:8.0.18-fpm-alpine

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN addgroup -g 1000 dev
RUN adduser -u 1000 -G dev -h /home/dev -D dev

RUN sed -i "s/user = www-data/user = dev/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = dev/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo pdo_mysql

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN apk add --no-cache \
      freetype \
      libjpeg-turbo \
      libpng \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && rm -rf /tmp/*

RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} && pecl install redis && docker-php-ext-enable redis

WORKDIR /home/dev/apps

RUN chown -R www-data:www-data /home/dev/apps

USER dev

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
