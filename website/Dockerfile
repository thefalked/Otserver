# Build from repo root: docker compose build website

FROM php:8.5-apache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	libpng-dev libjpeg62-turbo-dev libfreetype6-dev gettext-base \
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
  'default_charset = UTF-8' \
  'session.cookie_httponly = 1' \
  'session.use_strict_mode = 1' \
  'expose_php = Off' \
  > /usr/local/etc/php/conf.d/aac.ini

# Hide Apache/PHP fingerprints (F1): no version in Server/X-Powered-By or 404 footers.
# security.conf ships ServerTokens OS / ServerSignature On — override those first.
RUN sed -i \
  -e 's/^ServerTokens OS/ServerTokens Prod/' \
  -e 's/^ServerSignature On/ServerSignature Off/' \
  /etc/apache2/conf-available/security.conf \
 && printf '%s\n' \
  'Header always unset X-Powered-By' \
  'Header always unset Server' \
  'Header always set X-Content-Type-Options "nosniff"' \
  'Header always set X-Frame-Options "SAMEORIGIN"' \
  'Header always set Referrer-Policy "strict-origin-when-cross-origin"' \
  > /etc/apache2/conf-available/zzz-hardening.conf \
  && a2enconf zzz-hardening

RUN printf '%s\n' 'ServerName baiakvip9.thefalked.dev' \
  > /etc/apache2/conf-available/servername.conf \
  && a2enconf servername

COPY docker/render-config.sh /usr/local/bin/render-config.sh
COPY docker/ensure-schema.php /usr/local/bin/ensure-schema.php
COPY website/docker-entrypoint.sh /usr/local/bin/website-entrypoint.sh
RUN mkdir -p /usr/local/share/otserver \
 && chmod +x /usr/local/bin/render-config.sh /usr/local/bin/website-entrypoint.sh
COPY docker/mysql/07-lottery.sql /usr/local/share/otserver/07-lottery.sql
COPY docker/mysql/08-god-energy.sql /usr/local/share/otserver/08-god-energy.sql
COPY docker/mysql/09-hide-sample-chars.sql /usr/local/share/otserver/09-hide-sample-chars.sql

WORKDIR /var/www/html
ENTRYPOINT ["website-entrypoint.sh"]
