#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor;
use File::Path qw(make_path remove_tree);
use File::Spec::Functions qw(catfile abs2rel);
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use POSIX qw(strftime);

################################################################################
# FTP SETUP SCRIPT FOR vsftpd
#
# Required ENV:
#   FTP_USER_FILE       – path to file with FTP username
#   FTP_PASSWORD_FILE   – path to file with FTP password
#   WORDPRESS_VOLUME    – (optional) host path to mount into /files/
################################################################################

sub timestamp
{
    return strftime('%Y-%m-%d %H:%M:%S', localtime);
}

sub log_step
{
    my ($message) = @_;
    print "[" . timestamp() . "] $message\n";
}

sub fail_if
{
    my ($code, $step) = @_;
    if ($code != 0)
	{
        die "[" . timestamp() . "] ERROR during $step (exit=$code)\n";
    }
}
sub read_secret {
    my ($path) = @_;
    open my $fh, '<', $path
      or die "FTP ERROR: Cannot open secret file '$path': $!";
    chomp( my $val = <$fh> // '' );
    close $fh;
    die "FTP ERROR: Secret file '$path' is empty" unless length $val;
###
	print color('bold red');
	print "\t[$val].\n";
	print color('reset');
###
    return $val;
}

# Load and validate inputs
my $ftp_user = read_secret( $ENV{FTP_USER_FILE}    || '' );
my $ftp_pwd  = read_secret( $ENV{FTP_PASSWORD_FILE} || '' );
my $wp_vol   = $ENV{WORDPRESS_VOLUME} // '';

# Ensure username matches a safe pattern
die "FTP ERROR: Invalid username '$ftp_user'\n"
  unless $ftp_user =~ /^[a-z0-9_][a-z0-9_\-]*$/i;

log_step("FTP: Configuring user\n");

# 1) Create system user if missing
if (getpwnam $ftp_user) {
    print "FTP: user '$ftp_user' already exists, skipping creation\n";
}
else {
    system(
        'useradd',
        '--create-home',
        '--home-dir', "/home/$ftp_user",
        '--shell',     '/usr/sbin/nologin',
        '--user-group',
        $ftp_user
    ) == 0
      or die "FTP ERROR: useradd failed: exit=$?\n";
}

# extra step) 
####################################################################################



# --- Create FTP root folder ---
my $ftp_root = "/home/$ftp_user/ftp";
unless (-d $ftp_root) {
    log_step("Creating FTP root folder: $ftp_root");
    mkdir($ftp_root, 0755)
        or die "[" . timestamp() . "] ERROR: Failed to create $ftp_root: $!\n";
} else {
    log_step("FTP root folder already exists: $ftp_root");
}

log_step("Setting ownership to nobody:nogroup on $ftp_root");
fail_if(system("chown nobody:nogroup $ftp_root"), "chown on $ftp_root");

log_step("Setting permissions to 0555 on $ftp_root");
chmod(0555, $ftp_root)
    or die "[" . timestamp() . "] ERROR: chmod failed on $ftp_root: $!\n";

# --- Create files subfolder ---
my $files_dir = "$ftp_root/files";
unless (-d $files_dir) {
    log_step("Creating FTP files folder: $files_dir");
    mkdir($files_dir, 0755)
        or die "[" . timestamp() . "] ERROR: Failed to create $files_dir: $!\n";
} else {
    log_step("FTP files folder already exists: $files_dir");
}

log_step("Setting ownership to $ftp_user:$ftp_user on $files_dir");
fail_if(system("chown $ftp_user:$ftp_user $files_dir"), "chown on $files_dir");

log_step("Setting permissions to 0755 on $files_dir");
chmod(0755, $files_dir)
    or die "[" . timestamp() . "] ERROR: chmod failed on $files_dir: $!\n";

log_step("✅ FTP folder structure configured successfully");
####################################################################################

# 2) Set password
{
    open my $ch, '|-', 'chpasswd'
      or die "FTP ERROR: Cannot invoke chpasswd: $!";
    print $ch "$ftp_user:$ftp_pwd\n";
    close $ch
      or die "FTP ERROR: chpasswd reported failure: exit=$?\n";
}

# 3) Register user in vsftpd.userlist
my $userlist = '/etc/vsftpd.userlist';
{
    my %seen;
    if (-e $userlist) {
        open my $ul, '<', $userlist
          or die "FTP ERROR: Cannot read $userlist: $!";
        %seen = map { chomp; ($_ => 1) } <$ul>;
        close $ul;
    }
    open my $ul, '>>', $userlist
      or die "FTP ERROR: Cannot write to $userlist: $!";
    unless ($seen{$ftp_user}) {
        print $ul "$ftp_user\n";
    }
    close $ul;
}

# Handle optional WP volume or plain 'files' folder
if ( $wp_vol && -d $wp_vol ) {
    # clean any existing files_dir
    remove_tree( $files_dir, { error => \my $err } );
    symlink $wp_vol, $files_dir
      or die timestamp(), " FTP ERROR: symlink $wp_vol -> $files_dir failed: $!\n";
}
else {
    # pure directory layout
    unless ( -d $files_dir ) {
        make_path( $files_dir, { mode => 0755 } );
    }
    die timestamp(), " FTP ERROR: cannot create $files_dir: $!\n"
      unless -d $files_dir;
}

# Secure permissions
chmod 0555, $ftp_root
  or die timestamp(), " FTP ERROR: chmod $ftp_root: $!\n";

# Set ownership
chown scalar(getpwnam('nobody')), scalar(getgrnam('nogroup')), $ftp_root;
chown scalar(getpwnam($ftp_user)), scalar(getpwnam($ftp_user)), $files_dir;
###############################################################################

my $conf = <<"EOF";
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40005
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.userlist
local_root=/home/$ftp_user/ftp/files
EOF

open my $cfh, '>>', '/etc/vsftpd.conf' or die "…";
print $cfh $conf;
close $cfh;


# 6) Drop into vsftpd
log_step("FTP: Starting vsftpd\n");
  exec '/usr/sbin/vsftpd',
     '-olisten=YES',
     '-obackground=NO',
     '/etc/vsftpd.conf'
  or die "FTP ERROR: exec vsftpd failed: $!\n";

