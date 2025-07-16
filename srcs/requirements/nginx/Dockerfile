# **************************************************************************** #
#                                                                              #
#    Host: e3r7p3.42roma.it                                           /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/13 16:45:01 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/16 18:23:01                                   /          #
#    OS: Linux 6.5.0-44-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# Dockerfile for nginx


#TODO:
FROM debian:oldstable

# Install NGINX and OpenSSL, then clean up APT cache
RUN apt-get update -y \
 && apt-get install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

# Create a directory for TLS files and generate a self-signed certificate
RUN mkdir -p /etc/nginx/ssl \
 && openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=localhost"

# Copy your custom server configuration with TLS settings
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Run NGINX as PID 1 for proper signal handling (exec form)
ENTRYPOINT ["nginx", "-g", "daemon off;"]

