# Use the official PHP image as the base image
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www

# Install (necessary) system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath zip

# Install Redis PHP extension
RUN pecl install redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

EXPOSE 9000

CMD ["php-fpm"]
