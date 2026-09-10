FROM php:8.2-apache

RUN apt-get update \
 && apt-get install -y --no-install-recommends libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo pdo_mysql gd \
 && a2enmod rewrite headers \
 && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
 && rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' \
  'error_reporting = E_ALL' \
  'display_errors = Off' \
  'log_errors = On' \
  'error_log = /proc/self/fd/2' \
  'session.cookie_httponly = 1' \
  'session.use_strict_mode = 1' \
  > /usr/local/etc/php/conf.d/aac.ini

WORKDIR /var/www/html
