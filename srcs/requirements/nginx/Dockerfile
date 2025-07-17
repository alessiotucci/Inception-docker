# **************************************************************************** #
#                                                                              #
#    Host: e3r7p3.42roma.it                                           /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/13 16:45:01 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/17 10:49:44                                   /          #
#    OS: Linux 6.5.0-44-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# Dockerfile for nginx
# Use Debian's 'oldstable' base image for long-term support stability
FROM debian:oldstable-slim

# Install NGINX and OpenSSL with APT package manager
# - '--no-install-recommends' avoids unnecessary dependencies
# - '&& rm -rf /var/lib/apt/lists/*' cleans up package lists to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    vim \
    openssl && \
    rm -rf /var/lib/apt/lists/*

# Create SSL certificate storage directory
#  /etc/nginx/ssl: Standard location for NGINX SSL certificates
#  700 permissions: Owner (root) can read/write/execute, others have no access
#  NGINX requires certificates to be in a secure, dedicated location
RUN mkdir -p /etc/nginx/ssl && \
    chmod 700 /etc/nginx/ssl

# Generate self-signed TLS certificate
# - req: PKCS#10 certificate request utility
# - -x509: Output self-signed certificate instead of CSR
# - -nodes: "No DES" - don't encrypt private key
# - -days 365: Certificate validity period
# - -newkey rsa:2048: Generate 2048-bit RSA key
# - -keyout: Private key output path
# - -out: Certificate output path
# - -subj: Subject details (CN=localhost for local development)
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=localhost"

# Set strict permissions for certificate files
#  Prevent unauthorized access to private keys
RUN chmod 600 /etc/nginx/ssl/nginx.key && \
    chmod 644 /etc/nginx/ssl/nginx.crt

# Create NGINX configuration directory structure
# - /var/cache/nginx: NGINX cache storage
# - /var/log/nginx: NGINX log storage
# - /run/nginx: PID file storage (runtime state)
# Why needed: These are default directories NGINX requires to operate correctly
RUN mkdir -p \
    /var/cache/nginx \
    /var/log/nginx \
    /run/nginx && \
    # Set appropriate ownership for NGINX working directories
    chown -R www-data:www-data \
        /var/cache/nginx \
        /var/log/nginx \
        /run/nginx

# Copy custom NGINX configuration
# - This overwrites the default configuration
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy and prepare Perl entrypoint script
COPY ./script/nginx.pl /usr/local/bin/
# Make script executable
RUN chmod +x /usr/local/bin/nginx.pl

# Set entrypoint script to handle initialization
# Why needed: To perform runtime configuration before starting NGINX
ENTRYPOINT ["/usr/local/bin/nginx.pl"]

# Default command to start NGINX in foreground
# - 'nginx': Start NGINX master process
# - '-g daemon off;': Run in foreground (required for Docker containers)
CMD ["nginx", "-g", "daemon off;"]
