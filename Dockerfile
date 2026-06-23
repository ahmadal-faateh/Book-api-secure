FROM php:8.2-apache

# Install required packages
RUN apt-get update && apt-get install -y git unzip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project
COPY . /var/www/html

# Install PHP dependencies
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader

# Set Apache document root to /public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Allow .htaccess
RUN printf '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n' > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override