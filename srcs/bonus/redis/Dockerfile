# **************************************************************************** #
#                                                                              #
#    Host: atucci-Surface-Laptop-3                                    /_/      #
#    File: Dockerfile                                              ( o.o )     #
#    Created: 2025/07/23 10:17:46 | By: atucci <marvin@42.fr>      > ^ <       #
#    Updated: 2025/08/03 20:21:29                                   /          #
#    OS: Linux 6.8.0-64-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

FROM debian:oldstable

RUN apt-get -y update && apt install redis-server -y

RUN echo "maxmemory 256mb" >> /etc/redis/redis.conf

RUN echo "maxmemory-policy allkeys-lru" >> /etc/redis/redis.conf

RUN sed -i -r "s/bind 127.0.0.1/#bind 127.0.0.0/" /etc/redis/redis.conf

CMD ["redis-server", "--protected-mode", "no"]
