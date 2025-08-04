#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Term::ANSIColor;
use IO::Socket::INET;
use Time::HiRes qw(sleep);


sub read_secret
{
    my ($file) = @_;
    return undef unless $file;
    open my $fh, '<', $file or die "WORDPRESS ERROR: Cannot open $file: $!";
    my $value = <$fh>;
    close $fh;
    chomp $value;
###
	print color('bold red');
	print "\t[$value].\n";
	print color('reset');
###
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

#################################################################################
#Perl provides a set of unary file-test operators—often called “flags” to check #
#various attributes of files and directories
#################################################################################

unless (-e $config) # -e check if the file exist
{
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
}

###############################################################################
# After writing wp-config.php:
# 1. Read admin credentials from secret files
# new (matches docker-compose)
my $adm_user_file = $ENV{'WORDPRESS_ADMIN_USER_FILE'}
    or die "WORDPRESS ERROR: WORDPRESS_ADMIN_USER_FILE not set";
my $adm_pass_file = $ENV{'WORDPRESS_ADMIN_PASSWORD_FILE'}
    or die "WORDPRESS ERROR: WORDPRESS_ADMIN_PASSWORD_FILE not set";

# read the actual secrets
my $adm_user = read_secret($adm_user_file) // die "WORDPRESS ERROR: admin user secret is empty";
print("WP DEBUG LOG: $adm_user\n");
my $adm_pass = read_secret($adm_pass_file) // die "WORDPRESS ERROR: admin password secret is empty";
print("WP DEBUG LOG: $adm_pass\n");
# In Perl, the // operator is the defined-or operator.
# It returns the left-hand side operand if it's defined (not undef); otherwise,
#  it returns the right-hand side operand.



# 2. Read other install parameters
# TODO: check this stuff, maybe put in the env
my $site_url   = $ENV{WORDPRESS_SITE_URL} or die "WORDPRESS ERROR: site url env not set";
my $site_title = $ENV{WORDPRESS_SITE_TITLE} or die "WORDPRESS ERROR: site title env not set";
my $admin_email= $ENV{WORDPRESS_ADMIN_EMAIL} or die "WORDPRESS ERROR: admin email env not";

###############################################################################
# 3. Run WP-CLI to install WordPress if not already installed
# -f $file Exists and is a plain file
###############################################################################

#unless (-f "/var/www/html/wp-includes/version.php")
unless (system("wp core is-installed --allow-root") == 0)
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

## 4. Ensure the admin user exists (idempotent)
my @check = (
  "wp", "user", "get", $adm_user,
  "--field=ID", "--allow-root"
); # creating a list to pass to sytem

if (system(@check) == 0)
{
    print "WORDPRESS: Admin user '$adm_user' already exists, skipping creation\n";
}
else
{
    print "WORDPRESS: Creating admin user '$adm_user'\n";
   my $cmd =
		" wp user create "
		. $adm_user . "  "
		. $admin_email
		. " --role=administrator"
		. " --allow-root"
		. " --user_pass=$adm_pass";
		
   print("DEBUG:[$cmd]\n");
    system($cmd) == 0
      or die "FAIL: Failed to create admin user";
  };
###############################################################################
# --- Configuration ---
my $redis_host = $ENV{REDIS_HOST} || 'redis';
my $redis_port = $ENV{REDIS_PORT} || 6379;
my $wait_secs  = 20;
my $interval   = 1;

# --- 1. Wait for Redis to be reachable ---
print "Waiting for Redis at $redis_host:$redis_port …\n";
my $ready;
for my $i (1 .. $wait_secs) {
    if ( my $sock = IO::Socket::INET->new(
            PeerHost => $redis_host,
            PeerPort => $redis_port,
            Proto    => 'tcp',
            Timeout  => 1,
        )
    ) {
        close $sock;
        $ready = 1;
        last;
    }
    printf "  retry %2d/%d …\n", $i, $wait_secs;
    sleep($interval);
}

die "ERROR: Redis never became available\n" unless $ready;
print "Redis is up!\n";

# --- 2. Ensure the Redis plugin is installed & activated ---
if ( system("wp plugin is-installed redis-cache --allow-root") != 0 ) {
    print "Installing redis-cache plugin …\n";
    system("wp plugin install redis-cache --activate --allow-root") == 0
      or die "FAIL: could not install Redis plugin\n";
}
else {
    print "Redis plugin already installed. Skipping install …\n";
}

# --- 3. Configure WP-Redis connection in wp-config.php ---
my @settings = (
    [WP_REDIS_HOST     => $redis_host],
    [WP_REDIS_PORT     => $redis_port],
    [WP_REDIS_TIMEOUT  => 1],
    [WP_REDIS_DATABASE => 0],
);

for my $pair (@settings) {
    my ($key, $val) = @$pair;
    print "Setting $key = $val …\n";
    system(
        "wp config set $key $val --raw --allow-root"
    ) == 0 or die "FAIL: could not set $key\n";
}

# --- 4. Enable the object cache if not already enabled ---
chomp( my $status = `wp redis status --allow-root 2>&1` );
if ( $status !~ /Status:\s*Enabled/ ) {
    print "Enabling Redis object cache …\n";
    system("wp redis enable --allow-root") == 0
      or die "FAIL: could not enable Redis cache\n";
}
else {
    print "Redis cache already enabled. Skipping enable …\n";
}

print "✅ WordPress + Redis setup complete!\n";
###############################################################################
my $var = '
▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄ ▗▄▄▖ ▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖ ▗▄▄▖
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌
▐▌ ▐▌▐▌ ▐▌▐▛▀▚▖▐▌  █▐▛▀▘ ▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖ ▝▀▚▖
▐▙█▟▌▝▚▄▞▘▐▌ ▐▌▐▙▄▄▀▐▌   ▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘▗▄▄▞▘



';
print ("\n$var\n");
exec(@ARGV);
