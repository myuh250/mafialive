FROM php:7.4-apache-bullseye

# Bullseye is archived; php:7.4 images still target it.
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
    && sed -i '/bullseye-updates/d' /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libicu-dev \
        default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo_mysql \
        gd \
        zip \
        intl \
        opcache \
        exif \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' \
        'memory_limit=256M' \
        'upload_max_filesize=64M' \
        'post_max_size=64M' \
        'max_execution_time=120' \
    > /usr/local/etc/php/conf.d/xenforo.ini

COPY public_html/ /var/www/html/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN mv /var/www/html/htaccess.txt /var/www/html/.htaccess \
    && chown -R www-data:www-data /var/www/html/data /var/www/html/internal_data \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && printf '%s\n' \
        'display_errors=Off' \
        'error_reporting=E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED & ~E_STRICT' \
        'log_errors=On' \
    >> /usr/local/etc/php/conf.d/xenforo.ini \
    && echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
