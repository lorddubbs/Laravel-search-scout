# Use the official PHP image as the base image
# Stage 1: Builder
FROM php:8.3-fpm AS builder

# Set working directory
WORKDIR /var/www

# Install (necessary) system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group
RUN groupadd -r appgroup && useradd -r -g appgroup -d /var/www -s /sbin/nologin appuser

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath zip

# Install Redis PHP extension
RUN pecl install redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files (for Composer install)
COPY . /var/www

# Change ownership of the application code before running Composer
RUN chown -R appuser:appgroup /var/www

# Install PHP dependencies using Composer as non-root user
USER appuser
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Revert back to root user to finalize permissions
USER root
RUN chown -R appuser:appgroup /var/www

# Stage 2: Final Image
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www

# Copy the non-root user and group from the builder stage
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy PHP extensions and configuration from the builder stage
COPY --from=builder /usr/local/etc/php /usr/local/etc/php
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/bin/php /usr/local/bin/php
COPY --from=builder /usr/local/lib/php /usr/local/lib/php

# Copy installed PHP dependencies from the builder stage
COPY --from=builder /var/www/vendor /var/www/vendor

# Copy the application code
COPY . /var/www

# Change ownership of the application code
RUN chown -R appuser:appgroup /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Switch to the non-root user
USER appuser

EXPOSE 9000

CMD ["php-fpm"]
