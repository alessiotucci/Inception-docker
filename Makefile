# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: atucci <atucci@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/06/06 22:01:11 by atucci            #+#    #+#              #
#    Updated: 2024/06/09 20:21:20 by atucci           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


#***********#
# Variables #
#***********#
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

#***************#
# Phony Targets #
#***************#
.PHONY: up down clean logs

#****************#
# Default target #
#****************#
all: up

#*****************************#
# Start the Docker containers #
#*****************************#
up:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d --build

#**************************************#
#Stop and remove the Docker containers #
#**************************************#
down:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down

#*************************#
#Clean the Docker volumes #
#*************************#
clean:
	@docker volume prune -f

#***************************************#
#Show the logs of the Docker containers #
#***************************************#
logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) logs

