FROM php:7.4.29-fpm-alpine

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN addgroup -g 1000 dev
RUN adduser -u 1000 -G dev -h /home/dev -D dev

RUN sed -i "s/user = www-data/user = dev/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = dev/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo pdo_mysql

RUN apk add --update \
		$PHPIZE_DEPS \
		freetype-dev \
		git \
		libjpeg-turbo-dev \
		libpng-dev \
		libxml2-dev \
		libzip-dev \
		openssh-client \
		php7-json \
		php7-openssl \
		php7-pdo \
		php7-pdo_mysql \
		php7-session \
		php7-simplexml \
		php7-tokenizer \
		php7-xml \
		imagemagick \
		imagemagick-libs \
		imagemagick-dev \
		php7-imagick \
		php7-pcntl \
		php7-zip \
		sqlite \
	&& docker-php-ext-install soap sockets exif bcmath pdo_mysql pcntl \
	&& docker-php-ext-configure gd --with-jpeg --with-freetype \
	&& docker-php-ext-install gd \
	&& docker-php-ext-install zip

RUN printf "\n" | pecl install \
		imagick && \
		docker-php-ext-enable --ini-name 20-imagick.ini imagick

RUN printf "\n" | pecl install \
		pcov && \
		docker-php-ext-enable pcov

RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} && pecl install redis && docker-php-ext-enable redis

WORKDIR /home/dev/apps

RUN chown -R www-data:www-data /home/dev/apps

USER dev

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
