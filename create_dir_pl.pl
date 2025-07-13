#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path);

# Create root directories
my @dirs = (
    'secrets',
    'srcs',
    'srcs/requirements',
    'srcs/requirements/bonus',
    'srcs/requirements/mariadb',
    'srcs/requirements/mariadb/conf',
    'srcs/requirements/mariadb/tools',
    'srcs/requirements/nginx',
    'srcs/requirements/nginx/conf',
    'srcs/requirements/nginx/tools',
    'srcs/requirements/tools',
    'srcs/requirements/wordpress',
    'srcs/requirements/wordpress/conf',
    'srcs/requirements/wordpress/tools',
);

# Create directories if they don't exist
foreach my $dir (@dirs) {
    unless (-d $dir) {
        make_path($dir) or die "Failed to create $dir: $!";
        print "Created directory: $dir\n";
    }
    else {
        print "Directory already exists: $dir\n";
    }
}

# Create files if they don't exist
my @files = (
    'Makefile',  # Will not overwrite if exists
    'secrets/credentials.txt',
    'secrets/db_password.txt',
    'secrets/db_root_password.txt',
    'srcs/docker-compose.yml',
    'srcs/.env',  # Will not overwrite if exists
    'srcs/requirements/mariadb/Dockerfile',
    'srcs/requirements/mariadb/.dockerignore',
    'srcs/requirements/nginx/Dockerfile',
    'srcs/requirements/nginx/.dockerignore',
    'srcs/requirements/wordpress/Dockerfile',
    'srcs/requirements/wordpress/.dockerignore',
);

foreach my $file (@files) {
    if (-e $file) {
        print "File already exists: $file (skipped)\n";
        next;
    }
    
    open(my $fh, '>', $file) or die "Failed to create $file: $!";
    close($fh);
    print "Created file: $file\n";
}

# Add sample content to .env ONLY if it didn't exist
unless (-e 'srcs/.env') {
    open(my $env_fh, '>', 'srcs/.env') or die $!;
    print $env_fh <<'END_ENV';
DOMAIN_NAME=your_login.42.fr
# MYSQL SETUP
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password
# WORDPRESS SETUP
WP_DB_HOST=mariadb
WP_DB_USER=wordpress_user
WP_DB_PASSWORD_FILE=/run/secrets/db_password
END_ENV
    close($env_fh);
    print "Created .env with sample content\n";
}

print "\nDirectory structure verified successfully!\n";
print "Existing files were preserved.\n";
