#!/usr/bin/perl

#
# Inception - wordpress.pl
# This script configures WordPress by creating the wp-config.php file.
# It waits for the database container to be ready, then uses environment
# variables and secrets to populate the configuration file.
#

# Enforce strict variable declarations and catch common errors.
use strict;
use warnings;

# Import the IO::Socket::INET module to check for network connectivity.
# This is a core module, so no extra installation is needed.
use IO::Socket::INET;

# Subroutine to read the content of a file.
# It's used to read secrets like passwords from files.
# Takes one argument: the file path.
# Returns the first line of the file, with leading/trailing whitespace removed.
sub read_secret_file {
    my ($file_path) = @_;
    open(my $fh, '<', $file_path) or die "Cannot open secret file $file_path: $!";
    my $secret = <$fh>;
    close($fh);
    chomp($secret);
    return $secret;
}

# --- Main Script Execution ---

print "WORDPRESS: Starting configuration script...\n";

# Define the full path to the WordPress configuration file.
my $wp_config_file = "/var/www/html/wp-config.php";

# Check if the config file already exists. If so, do nothing.
# This prevents the script from overwriting an existing configuration on container restart.
if (-e $wp_config_file) {
    print "WORDPRESS: Configuration file 'wp-config.php' already exists. Skipping setup.\n";
} else {
    print "WORDPRESS: 'wp-config.php' not found. Starting configuration process...\n";

    # Get database configuration from environment variables.
    # The names must match those in docker-compose.yml.
    my $db_host_port = $ENV{'WORDPRESS_DB_HOST'} or die "Error: WORDPRESS_DB_HOST environment variable not set.";
    my $db_name      = $ENV{'WORDPRESS_DB_NAME'} or die "Error: WORDPRESS_DB_NAME environment variable not set.";
    my $db_user_file = $ENV{'WORDPRESS_DB_USER_FILE'} or die "Error: WORDPRESS_DB_USER_FILE environment variable not set.";
    my $db_pass_file = $ENV{'WORDPRESS_DB_PASSWORD_FILE'} or die "Error: WORDPRESS_DB_PASSWORD_FILE environment variable not set.";
    
    # Read the user and password from the secret files.
    my $db_user      = read_secret_file($db_user_file);
    my $db_pass      = read_secret_file($db_pass_file);

    # Split the host and port from WORDPRESS_DB_HOST (e.g., 'mariadb:3306').
    my ($db_host, $db_port) = split(':', $db_host_port);
    $db_port = $db_port // 3306; # Default to 3306 if port is not specified.

    # --- Wait for the database to be available ---
    print "WORDPRESS: Waiting for database at $db_host:$db_port to be ready...\n";
    my $retries = 30; # Number of times to try connecting.
    my $is_db_ready = 0;
    while ($retries > 0) {
        # Try to create a TCP socket connection to the database host and port.
        my $socket = IO::Socket::INET->new(
            PeerAddr => $db_host,
            PeerPort => $db_port,
            Proto    => 'tcp',
            Timeout  => 5, # Set a timeout for the connection attempt.
        );
        # If the socket was created successfully, the database is ready.
        if ($socket) {
            $is_db_ready = 1;
            close($socket); # Close the connection immediately.
            last; # Exit the loop.
        }
        # If connection failed, wait for 2 seconds and try again.
        print "WORDPRESS: Database not responding, retrying in 2 seconds... ($retries attempts left)\n";
        sleep(2);
        $retries--;
    }

    # If the database did not become ready after all retries, exit with an error.
    die "FATAL: Could not connect to the database at $db_host:$db_port after multiple attempts." unless $is_db_ready;
    print "WORDPRESS: Database is ready! Proceeding with configuration.\n";

    # --- Generate wp-config.php ---
    my $wp_config_sample = "/var/www/html/wp-config-sample.php";
    open(my $in_fh, '<', $wp_config_sample) or die "Cannot read $wp_config_sample: $!";
    my $config_content = do { local $/; <$in_fh> }; # Slurp the entire file content.
    close($in_fh);

    # Replace the database credentials placeholders in the sample file content.
    $config_content =~ s/database_name_here/$db_name/g;
    $config_content =~ s/username_here/$db_user/g;
    $config_content =~ s/password_here/$db_pass/g;
    $config_content =~ s/localhost/$db_host_port/g;

    # Fetch unique authentication keys and salts from the official WordPress API.
    # This is a critical security step.
    print "WORDPRESS: Fetching unique security salts from WordPress.org API...\n";
    my $salts = `curl -s https://api.wordpress.org/secret-key/1.1/salt/`;
    die "Failed to fetch salts from WordPress API." if $?;
    
    # Replace the placeholder salt block with the newly fetched salts.
    # The 's' flag allows '.' to match newline characters.
    $config_content =~ s/\/\*\*#@\+.*?#@-\*\//\Q$salts\E/s;

    # Write the completed configuration to the final wp-config.php file.
    open(my $out_fh, '>', $wp_config_file) or die "Cannot write to $wp_config_file: $!";
    print $out_fh $config_content;
    close($out_fh);

    # Set the correct file ownership so the web server can read it.
    # 'www-data' is the user that PHP-FPM runs as in the Debian container.
    chown((getpwnam('www-data'))[2,3], $wp_config_file);

    print "WORDPRESS: 'wp-config.php' created and configured successfully.\n";
}

# Replace the current script process with the command from the Dockerfile's CMD (php-fpm7.4 -F).
# This ensures the PHP-FPM service runs as the main container process.
print "WORDPRESS: Handing over control to PHP-FPM...\n";
exec @ARGV;
