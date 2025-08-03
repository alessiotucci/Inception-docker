#!/usr/bin/perl
use strict;
use warnings;
use File::Copy qw(move);
use File::Path qw(remove_tree);
use Cwd;

print("Adminer\n");

print("Starting Adminer setup...\n");

# Download Adminer
my $url = 'http://www.adminer.org/latest.php';
my $output = '/var/www/html/adminer.php';
print("Downloading Adminer from $url...");

system("wget \"$url\" -O $output") == 0 or die "Download failed: $?";

# Change ownership
print("Changing ownership to www-data:www-data...\n");
system("chown -R www-data:www-data $output") == 0 or die "chown failed: $?";

# Set permission
print("Setting file permissions to 755...\n");
chmod (0755, $output) or die "chmod failed: $!";

# Change directory
print("Changing directory to /var/www/html...\n");
chdir("/var/www/html") or die "Failed to change directory: $!";

# Remove index.html
print("Removing index.html if it exists...\n");
remove_tree('index.html', {error => \my $err});
# Start PHP server
print("Starting PHP server on 0.0.0.0:8080...\n");
exec("php -S 0.0.0.0:8080") or die "Failed to start PHP server: $!";
