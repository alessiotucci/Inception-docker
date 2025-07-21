#!/usr/bin/perl

#
# Inception - mariadb.pl
# This script initializes the MariaDB database upon the container's first run.
# It creates the WordPress database, the user, and sets the root password
# using secrets passed as files via environment variables.
#

# Enforce strict variable declarations and catch common errors.
use strict;
use warnings;

# Subroutine to read the content of a file.
# It's used to read secrets like passwords from files.
# Takes one argument: the file path.
# Returns the first line of the file, with leading/trailing whitespace removed.
sub read_secret_file {
    # Get the file path from the function arguments.
    my ($file_path) = @_;
    # Open the file for reading or die with an error message.
    open(my $fh, '<', $file_path) or die "Cannot open secret file $file_path: $!";
    # Read the first line from the file handle.
    my $secret = <$fh>;
    # Close the file handle.
    close($fh);
    # Remove any newline characters.
    chomp($secret);
    # Return the secret.
    return $secret;
}

# --- Main Script Execution ---

print "MARIADB: Starting configuration script...\n";

# Define the path to the MariaDB data directory.
my $datadir = "/var/lib/mysql";

# Check if the database has already been initialized by looking for the 'mysql' system database folder.
# This ensures the initialization logic runs only once.
if (-d "$datadir/mysql") {
    print "MARIADB: Database already initialized. Skipping setup.\n";
} else {
    print "MARIADB: Database not found. Initializing for the first time...\n";

    # Get database configuration from environment variables.
    # The variable names must match those in the docker-compose.yml file.
    my $db_name     = $ENV{'MYSQL_DATABASE'} or die "Error: MYSQL_DATABASE environment variable not set.";
    my $db_user_file = $ENV{'MYSQL_USER_FILE'} or die "Error: MYSQL_USER_FILE environment variable not set.";
    my $db_pass_file = $ENV{'MYSQL_PASSWORD_FILE'} or die "Error: MYSQL_PASSWORD_FILE environment variable not set.";
    my $root_pass_file = $ENV{'MYSQL_ROOT_PASSWORD_FILE'} or die "Error: MYSQL_ROOT_PASSWORD_FILE environment variable not set.";

    # Read the secrets from the files using the subroutine defined above.
    my $db_user     = read_secret_file($db_user_file);
    my $db_pass     = read_secret_file($db_pass_file);
    my $root_pass   = read_secret_file($root_pass_file);

    print "MARIADB: Creating initial database structure...\n";
    # Run 'mysql_install_db' to create the default database files and system tables.
    # The user 'mysql' is specified as it's the dedicated user for running the database service.
    # The output is sent to /dev/null to keep the logs clean.
    system("mysql_install_db", "--user=mysql", "--datadir=$datadir") == 0
        or die "Failed to run mysql_install_db: $?";

    # Define the path for a temporary SQL script that will configure the database.
    my $init_sql_file = "/tmp/init.sql";

    # Open the temporary file for writing.
    open(my $fh, '>', $init_sql_file) or die "Cannot open temporary SQL file $init_sql_file: $!";

    # Write the necessary SQL commands to the temporary file.
    # This is a secure way to bootstrap the database with users and permissions.
    print $fh "
-- Reset all permissions to a clean state.
FLUSH PRIVILEGES;

-- Set the password for the 'root' user on 'localhost'.
ALTER USER 'root'\@'localhost' IDENTIFIED BY '$root_pass';

-- Create the WordPress database if it doesn't already exist.
CREATE DATABASE IF NOT EXISTS \`$db_name\`;

-- Create the WordPress user. The '%' host means the user can connect from any IP address
-- (which is needed for the WordPress container to connect over the Docker network).
CREATE USER '$db_user'\@'%' IDENTIFIED BY '$db_pass';

-- Grant all necessary privileges for the new user on the new database.
GRANT ALL PRIVILEGES ON \`$db_name\`.* TO '$db_user'\@'%';

-- Apply the new privilege rules immediately.
FLUSH PRIVILEGES;
";
    # Close the temporary SQL file.
    close($fh);

    print "MARIADB: Launching mysqld with init-file to apply configuration...\n";
    # Execute mysqld in bootstrap mode with our init script.
    # The '--init-file' option makes MariaDB run the SQL script on startup.
    # This is a safe and standard method for initial configuration.
    system("mysqld", "--user=mysql", "--datadir=$datadir", "--init-file=$init_sql_file") == 0
        or die "Failed to initialize MariaDB with init file: $?";
    
    # Clean up the temporary SQL file now that it has been used.
    unlink $init_sql_file;
    
    print "MARIADB: Initialization complete.\n";
}

# Replace the current Perl script process with the command specified in the Dockerfile's CMD.
# For this project, it will be 'mysqld_safe'.
# This is crucial for the container to stay running and for signals (like stop/kill) to be handled correctly.
print "MARIADB: Handing over control to mysqld_safe...\n";
exec @ARGV;
