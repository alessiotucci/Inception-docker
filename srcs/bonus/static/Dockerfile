# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/23 10:22:17 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/05 19:12:55                                   /          #
#    OS: Linux 6.8.0-64-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

FROM debian:oldstable

# Install NGINX (no meta-image), then clean up package cache
RUN apt-get update                                \
 && apt-get install -y --no-install-recommends \
 nginx              \
 && rm -rf /var/lib/apt/lists/*

# Copy our single-page site into NGINX’s default html directory
COPY index.html /usr/share/nginx/html/index.html

# Ensure NGINX can write its PID/run files
RUN mkdir -p /run/nginx

# Expose port 80 internally (still proxied by the main reverse-proxy, so we don't publish here)
EXPOSE 80

# Run NGINX in the foreground (required for Docker PID 1 best practices)
CMD ["nginx", "-g", "daemon off;"]

