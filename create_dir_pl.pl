#!/bin/perl

use strict;
use warnings;

# Create the necessary directories
system 'mkdir -p srcs/requirements/bonus';
system 'mkdir -p srcs/requirements/mariadb/conf';
system 'mkdir -p srcs/requirements/mariadb/tools';
system 'mkdir -p srcs/requirements/nginx/conf';
system 'mkdir -p srcs/requirements/nginx/tools';
system 'mkdir -p srcs/requirements/tools';
system 'mkdir -p srcs/requirements/wordpress';
system 'touch srcs/docker-compose.yml';
system 'touch srcs/.env';
system 'touch srcs/requirements/mariadb/Dockerfile';
system 'touch srcs/requirements/mariadb/.dockerignore';
system 'touch srcs/requirements/nginx/Dockerfile';
system 'touch srcs/requirements/nginx/.dockerignore';

# Print out the new directory structure
system 'ls -alR';

