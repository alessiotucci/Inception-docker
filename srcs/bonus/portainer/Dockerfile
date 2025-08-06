# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/08/06 16:26:15 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/06 16:44:43                                   /          #
#    OS: Linux 6.8.0-65-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# Start from Debian (mandatory as per subject)
FROM debian:oldstable

# Install required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download Portainer CE binary
RUN wget https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz -O /tmp/portainer.tar.gz && \
    mkdir -p /opt/portainer && \
    tar -xvzf /tmp/portainer.tar.gz -C /opt/portainer --strip-components=1 && \
    rm /tmp/portainer.tar.gz

# Expose Portainer UI port
EXPOSE 9000

# Set the data directory for Portainer
VOLUME ["/data"]

# Start Portainer in standalone mode
CMD ["/opt/portainer/portainer", "--data", "/data"]

