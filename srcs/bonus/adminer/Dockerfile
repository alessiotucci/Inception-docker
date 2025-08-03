# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/23 10:16:14 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/03 20:10:54                                   /          #
#    OS: Linux 6.8.0-64-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# bonus/adminer/Dockerfile
FROM debian:oldstable

# Install PHP & wget
RUN apt-get update && apt-get install -y \
      php \
      php-mysql \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Create a webroot and download Adminer there
WORKDIR /var/www/adminer
RUN wget -q https://www.adminer.org/latest.php -O index.php \
  && chown -R www-data:www-data /var/www/adminer \
  && chmod 755 /var/www/adminer/index.php

# Expose the internal port only
EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]

