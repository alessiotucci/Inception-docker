# **************************************************************************** #
#                                                                              #
#    Host: e3r7p3.42roma.it                                           /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/13 16:44:47 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/22 09:50:45                                   /          #
#    OS: Linux 6.5.0-44-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# Dockerfile for MariaDB
FROM debian:oldstable

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install mariadb-server and basic tools
RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Expose the default MariaDB port
EXPOSE 3306

# Create the required directories (if not already created by package)
RUN mkdir -p /run/mysqld

# Make sure mysql can write to its folders
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Declare volume for persistent storage
VOLUME /var/lib/mysql

# Copy and prepare Perl entrypoint script
COPY ./script/mariadb.pl /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.pl

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/mariadb.pl"]

# Start MariaDB server in foreground mode so the container keeps running
CMD ["mysqld_safe"]

