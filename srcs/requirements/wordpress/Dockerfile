# **************************************************************************** #
#                                                                              #
#    Host: e3r7p3.42roma.it                                           /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/13 16:45:17 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/18 17:58:41                                   /          #
#    OS: Linux 6.5.0-44-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# Dockerfile for Wordpress
#TODO: remember that old stable point to the penultimate availabe!
FROM debian:oldstable
# Prevent interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and PHP-FPM
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    php \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for WordPress
WORKDIR /var/www/html

# Download and extract latest WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz && \
    cp -a wordpress/. . && \
    rm -rf wordpress latest.tar.gz

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose the port php-fpm will listen on
# (Remember: this is only useful if using TCP sockets, not unix socket)
EXPOSE 9000

RUN mkdir -p /run/php
# Start PHP-FPM in the foreground (PID 1)
CMD ["php-fpm7.4","-F"]

