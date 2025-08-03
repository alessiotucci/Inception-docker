# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/23 10:16:14 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/03 17:55:17                                   /          #
#    OS: Linux 6.8.0-64-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

FROM debian:oldstable

RUN apt-get update && apt-get install -y \
    php \
    php-mysql \
    vim \
    wget

COPY ./script/adminer.pl /usr/local/bin/
RUN chmod +x /usr/local/bin/adminer.pl

# Expose default port (Adminer typically uses 8080)
EXPOSE 8080

# Use exec form for proper signal handling
ENTRYPOINT ["/usr/local/bin/adminer.pl"]

# Default arguments (port number)
CMD ["8080"]
