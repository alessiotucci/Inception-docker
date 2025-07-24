#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

sub read_secret
{
    my ($file) = @_;
    return undef unless $file;
    open my $fh, '<', $file or die "WORDPRESS ERROR: Cannot open $file: $!";
    my $value = <$fh>;
    close $fh;
    chomp $value;
    return $value;
}

print "WORDPRESS: Starting configuration...\n";

# Get env variables
my $db_host = $ENV{'WORDPRESS_DB_HOST'} or die "WORDPRESS ERROR: WORDPRESS_DB_HOST not set";
my $db_name = $ENV{'WORDPRESS_DB_NAME'} or die "WORDPRESS ERROR: WORDPRESS_DB_NAME not set";
my $user_file = $ENV{'WORDPRESS_DB_USER_FILE'} or die "WORDPRESS ERROR: Secret file path not provided";
my $pass_file = $ENV{'WORDPRESS_DB_PASSWORD_FILE'} or die "WORDPRESS ERROR: Secret file path not provided";



# Read secrets
my $db_user = read_secret($user_file);
my $db_pass = read_secret($pass_file);

# Wait for DB
print "WORDPRESS: Waiting for DB ($db_host)...\n";
my ($host, $port) = split(':', $db_host);
$port ||= 3306;

for my $try (1..60)
{
    my $sock = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port, Proto => 'tcp', Timeout => 2);
    if ($sock)
	{
        close($sock);
        print "WORDPRESS: DB is up!\n";
        last;
    }
    print "WORDPRESS: DB not ready ($try/60), retrying...\n";
    sleep 2;
}


## Generate wp-config.php if not exists
my $config = "/var/www/html/wp-config.php";
    print "WORDPRESS: Creating wp-config.php\n";

    open my $in, "<", "/var/www/html/wp-config-sample.php" or die "Can't read sample config: $!";
    my $content = do { local $/; <$in> };
    close $in;

    $content =~ s/database_name_here/$db_name/g;
    $content =~ s/username_here/$db_user/g;
    $content =~ s/password_here/$db_pass/g;
    $content =~ s/localhost/$host/g;

    # Get unique salts
    my $salts = `curl -s https://api.wordpress.org/secret-key/1.1/salt/`;
    $content =~ s/\/\*\*#@\+.*?#@-\*\//$salts/s;

    open my $out, ">", $config or die "Can't write config: $!";
    print $out $content;
    close $out;

###############################################################################
# After writing wp-config.php:
# 1. Read admin credentials from secret files
my $adm_user = 'admin';#   = $ENV{'WORDPRESS_AD_FILE'}         or die "No WORDPRESS_AD_FILE";
print("admin: $adm_user\n");

my $adm_pass = 'password'; #$ENV{'WORDPRESS_AD_PASSWORD_FILE'} or die "No WORDPRESS_AD_PASSWORD_FILE";
printf("password: $adm_pass\n");

# 2. Read other install parameters
my $site_url   = "test";
my $site_title = "test";
my $admin_email= 'test@gmail.com';

# 3. Run WP-CLI to install WordPress if not already installed
unless (-f "/var/www/html/wp-includes/version.php")
{
my $cmd = 
  "wp core install "
  . " --url=$site_url "
  . " --title='$site_title' "
  . " --admin_user=$adm_user "
  . " --admin_password=$adm_pass "
  . " --admin_email=$admin_email "
  . " --allow-root"
  . " --skip-email";

print("DEBUG:[$cmd]\n");
system($cmd) == 0
  or die "FAIL: wp core install failed (exit code: $?)";

}

# 4. Ensure the admin user exists (idempotent)
#system("wp user get $adm_user --field=ID") == 0
#  or do
{
   my $cmd =
		" wp user create "
		. $adm_user . " "
		. $admin_email
		. " --role=administrator"
		. " --allow-root"
		. " --user_pass=$adm_pass";
		
   print("DEBUG:[$cmd]");
    system($cmd) == 0
      or die "FAIL: Failed to create admin user";
  };
###############################################################################

my $var = '
▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄ ▗▄▄▖ ▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖ ▗▄▄▖
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌
▐▌ ▐▌▐▌ ▐▌▐▛▀▚▖▐▌  █▐▛▀▘ ▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖ ▝▀▚▖
▐▙█▟▌▝▚▄▞▘▐▌ ▐▌▐▙▄▄▀▐▌   ▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘▗▄▄▞▘



';
print ("\n$var\n");
exec(@ARGV);
