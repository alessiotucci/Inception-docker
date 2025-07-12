#!/usr/bin/perl
# Import necessary Perl modules
use strict;
use warnings;
use Term::ANSIColor;

# Define the domain to be used in the script
my $domain = "atucci.42.fr";

# Function to print colored messages
sub print_message()
{
	my ($color, $message) = @_;
	print color($color), $message, color('reset'), "\n";
}

# Function to execute a command and print a message
sub execute_command()
{
	my ($color, $message, $command) = @_;
	# Print the message
	print_message($color, $message);
	system($command) if $command;
}

# Function to update the system
sub update_system()
{
	# Execute the system update command
	execute_command('magenta', 'Updating system...', 'sudo apt update > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1');
	execute_command('green', 'Done.', '');
}

# Function to install packages
sub install_packages()
{
	my @packages = @_;
	# Loop over each package
	for my $package (@packages)
	{
		execute_command('magenta', "Installing $package...", "sudo apt install -y $package > /dev/null 2>&1");
		execute_command('green', 'Done.', '');
	}
}

# Function to set up localhost
sub setup_localhost
{
	# Check if the domain is already set up
	unless (`grep -q $domain /etc/hosts`)
	{
		# Execute the command to set up the domain as localhost
		execute_command('magenta', "Setting up $domain as localhost", "echo '127.0.0.1\t$domain' | sudo tee -a /etc/hosts > /dev/null");
		# Print a completion message
		execute_command('green', 'Done.', '');
	}
}

# Function to install Docker
sub install_docker
{
	# Execute the command to install Docker dependencies
	execute_command('magenta', 'Installing Docker dependencies...', 'sudo apt install -y apt-transport-https ca-certificates curl software-properties-common > /dev/null 2>&1');
	# Print a completion message
	execute_command('green', 'Done.', '');
	# Execute the command to download and add Docker GPG key
	execute_command('magenta', 'Downloading and adding Docker GPG key...', 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1');
	# Print a completion message
	execute_command('green', 'Done.', '');
	# Execute the command to add Docker repository
	execute_command('magenta', 'Adding Docker repository...', 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null 2>&1');
	# Print a completion message
	execute_command('green', 'Done.', '');
	# Execute the command to install Docker
	execute_command('magenta', 'Installing Docker...', 'sudo apt install docker-ce -y > /dev/null 2>&1');
	# Print a completion message
	execute_command('green', 'Done.', '');
	# Add the current user to the Docker group
	system("sudo usermod -aG docker $ENV{USER}");
}

# Function to prompt for reboot
sub prompt_reboot
{
	# Ask the user if they want to reboot
	print_message('yellow', 'Configuration completed. Do you want to reboot now? (yes/no)');
	chomp(my $input = <STDIN>);
	if (lc($input) eq 'yes')
	{
		# If the user wants to reboot, print a message and reboot after 5 seconds
		print_message('green', 'Rebooting in 5 seconds...');
		sleep 5;
		system('sudo reboot');
	}
	else
		print_message('green', 'Reboot skipped. Please reboot manually if needed.');
}

# Main execution
# Update the system
update_system();
install_packages('git', 'make', 'vim', 'docker.io', 'docker-compose', 'perl');
setup_localhost();
install_docker();
prompt_reboot();
