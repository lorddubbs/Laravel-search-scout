# Stage 1: Dependencies
FROM composer:2.5.8 as vendor

WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --ansi --no-interaction --prefer-dist

# Stage 2: Application
FROM php:8.3-fpm

WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath zip
RUN pecl install redis \
    && docker-php-ext-enable redis

# Create a non-root user
ARG USER_ID=1000
RUN groupadd -g $USER_ID appgroup && useradd -u $USER_ID -g appgroup -d /var/www appuser

# Copy application
COPY . /var/www
COPY --from=vendor /var/www/vendor ./vendor

# Copy Composer binary from the vendor stage
COPY --from=vendor /usr/bin/composer /usr/bin/composer

# Set correct permissions
RUN chown -R appuser:appgroup /var/www \
    && chmod -R 755 /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Switch to non-root user
USER appuser

# Generate optimized autoload files
RUN composer dump-autoload --optimize --ansi --no-dev

EXPOSE 9000

CMD ["php-fpm"]
