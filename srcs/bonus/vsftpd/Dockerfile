# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/23 10:20:37 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/04 18:30:17                                   /          #
#    OS: Linux 6.8.0-64-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

FROM debian:oldstable

# Non-interactive install (no prompts)
ENV DEBIAN_FRONTEND=noninteractive

# Install vsftpd and required utilities
RUN apt-get update && apt-get install -y \
	 vsftpd \
	 perl \
	 libfile-path-perl \
	 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create FTP configuration and userlist directories
RUN mkdir -p /var/run/vsftpd/empty && mkdir -p /etc/vsftpd

# Copy Perl setup script
COPY ./script/vsftpd.pl /usr/local/bin/vsftpd.pl
RUN chmod +x /usr/local/bin/vsftpd.pl

# Expose FTP control port and passive ports
EXPOSE 21 40000-40005

# Entrypoint: run the perl script
ENTRYPOINT ["/usr/local/bin/vsftpd.pl"]

# Start vsftpd in the foreground
CMD ["/usr/sbin/vsftdp"]
