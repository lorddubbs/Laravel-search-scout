# Stage 1: Dependencies
FROM composer:2.5.8 as vendor

WORKDIR /app

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
RUN pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug

# Copy application
COPY . .
COPY --from=vendor /app/vendor ./vendor

# Install Composer
COPY --from=composer:2.5.8 /usr/bin/composer /usr/bin/composer

# Create a non-root user
RUN groupadd -g 1000 appgroup && useradd -u 1000 -g appgroup -d /var/www appuser

# Set correct permissions after creating the user
RUN chown -R appuser:appgroup /var/www \
    && chmod -R 755 /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Switch to non-root user
USER appuser

# Generate optimized autoload files
RUN composer dump-autoload --optimize --ansi --no-dev

EXPOSE 9000

CMD ["php-fpm"]
