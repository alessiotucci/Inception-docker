#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor;

my $domain = "atucci.42.fr";

sub print_message
{
	my ($color, $message) = @_;
	print color($color), $message, color('reset'), "\n";
}

sub execute_command
{
	my ($color, $message, $command) = @_;
	print_message($color, $message);
	system($command) if $command;
}

sub update_system
{
	execute_command('magenta', 'Updating system...', 'sudo apt update > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
}

sub install_packages {
	my @packages = @_;
	for my $package (@packages) {
		execute_command('magenta', "Installing $package...", "sudo apt install -y $package > /dev/null 2>&1");
		execute_command('green', 'Done.', '');
	}
}


sub setup_localhost
{
	unless (`grep -q $domain /etc/hosts`)
	{
		execute_command('magenta', "Setting up $domain as localhost", "echo '127.0.0.1\t$domain' | sudo tee -a /etc/hosts > /dev/null");
		execute_command('green', 'Done.', '');
	}
}

sub install_docker
{
	execute_command('magenta', 'Installing Docker dependencies...', 'sudo apt install -y apt-transport-https ca-certificates curl software-properties-common > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
	execute_command('magenta', 'Downloading and adding Docker GPG key...', 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
	execute_command('magenta', 'Adding Docker repository...', 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
	execute_command('magenta', 'Installing Docker...', 'sudo apt install docker-ce -y > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
	system("sudo usermod -aG docker $ENV{USER}");
}

sub prompt_reboot
{
	print_message('yellow', 'Configuration completed. Do you want to reboot now? (yes/no)');
	chomp(my $input = <STDIN>);
	if (lc($input) eq 'yes')
	{
		print_message('green', 'Rebooting in 5 seconds...');
		sleep 5;
		system('sudo reboot');
	}
	else
	{
		print_message('green', 'Reboot skipped. Please reboot manually if needed.');
	}
}

# Main execution
update_system();
install_packages('git', 'make', 'vim', 'docker.io', 'docker-compose', 'perl');
setup_localhost();
install_docker();
prompt_reboot();

