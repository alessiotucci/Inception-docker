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
# Here I can add the new secrets

# Read secrets
my $db_user = read_secret($user_file);
my $db_pass = read_secret($pass_file);
# Here I can read the new secrets

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

my $var = '
▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄ ▗▄▄▖ ▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖ ▗▄▄▖
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌  █▐▌ ▐▌▐▌ ▐▌▐▌   ▐▌   ▐▌
▐▌ ▐▌▐▌ ▐▌▐▛▀▚▖▐▌  █▐▛▀▘ ▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖ ▝▀▚▖
▐▙█▟▌▝▚▄▞▘▐▌ ▐▌▐▙▄▄▀▐▌   ▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘▗▄▄▞▘



';
print ("\n$var\n");
exec(@ARGV);
