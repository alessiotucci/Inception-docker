#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

# Print ASCII
my $ascii = '       ▘  ▄ ▄ 
▛▛▌▀▌▛▘▌▀▌▌▌▙▘
▌▌▌█▌▌ ▌█▌▙▘▙▘
              ';
print("\n$ascii\n");

# Read secret file
sub read_secret {
    my ($file) = @_;
    open my $fh, '<', $file or die "MARIADB ERROR: Cannot open secret $file: $!";
    my $val = <$fh>;
    close $fh;
    chomp $val;
    return $val;
}

# Read secrets
my $root_pass = read_secret("/run/secrets/db_root_password.txt");
my $db_name   = "wordpress"; # static name as per subject
my $user      = read_secret("/run/secrets/db_user.txt");
my $pass      = read_secret("/run/secrets/db_user_password.txt");

# Start mysqld_safe in background
print "MARIADB: Starting mysqld_safe...\n";
my $pid = fork();
if ($pid == 0) {
    exec("mysqld_safe");
    exit(1); # If exec fails
}

# Wait for MySQL to be ready on 127.0.0.1:3306
print "MARIADB: Waiting for MySQL on 127.0.0.1:3306...\n";
my $ready = 0;
for my $try (1..30) {
    my $sock = IO::Socket::INET->new(PeerAddr => "127.0.0.1", PeerPort => 3306, Proto => 'tcp', Timeout => 2);
    if ($sock) {
        $ready = 1;
        close($sock);
        last;
    }
    print "MARIADB: Try $try/30 failed; retry in 2s\n";
    sleep 2;
}

die "MARIADB FATAL: MySQL never came up\n" unless $ready;

print "MARIADB: Connected. Running initialization SQL...\n";

# Prepare and run SQL commands
my $sql = qq{
    CREATE DATABASE IF NOT EXISTS $db_name;
    CREATE USER IF NOT EXISTS '$user'\@'%' IDENTIFIED BY '$pass';
    GRANT ALL PRIVILEGES ON $db_name.* TO '$user'\@'%';
    FLUSH PRIVILEGES;
};

system("mysql", "-uroot", "-p$root_pass", "-e", $sql) == 0
    or die "MARIADB ERROR: Failed to run initialization SQL\n";

print "MARIADB: Initialization complete. Handing over to mysqld_safe...\n";

#osema debug
#exec("/etc/init.d/mariadb restart");

# Wait for mysqld_safe (PID 1) to stay alive
waitpid($pid, 0);
#
#my $ascii = '       ▘  ▄ ▄ 
#▛▛▌▀▌▛▘▌▀▌▌▌▙▘
#▌▌▌█▌▌ ▌█▌▙▘▙▘
#              ';
#
#
#print("\n$ascii\n");
#exec(@ARGV);
#!/usr/bin/perl


