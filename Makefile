# **************************************************************************** #
#                                                                              #
#    Host: e4r2p4.42roma.it                                           /_/      #
#    File: Makefile                                                ( o.o )     #
#    Created: 2025/07/12 17:34:26 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/13 19:10:56                                   /          #
#    OS: Linux 6.5.0-44-generic x86_64 | CPU: Intel(R) Core(TM) i (|_|)_)      #
#                                                                              #
# **************************************************************************** #

# *********** #
# Color codes #
# *********** #
GREEN = \033[1;32m
CYAN = \033[1;36m
YELLOW = \033[1;33m
RED = \033[1;31m
RESET = \033[0m

#---TODO: check if need to use whoami
USERNAME = atucci
PROJECTNAME = Inception

#--- with this variable we are specify where to find the docker compose
COMPOSE = docker-compose -f srcs/docker-compose.yml
ENV_FILE = srcs/.env

# ******************************************** #
# DEFAULT RULE: build and start the containers #
# ******************************************** #
all: build up
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) default"
	@echo "$(GREEN) building and starting the containers -> build -> up $(RESET)"

# ********************************************* #
# BUILD RULE: this rule build up all the images #
# ********************************************* #
build:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) build rule!"
	$(COMPOSE) build

# ************************ #
# UP RULE:                 #
# ************************ #
up:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) up rule!"
	${COMPOSE} up -d

# ************************ #
# DOWN RULE:               #
# ************************ #
down:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) down rule!"
	$(COMPOSE) down


# ************************ #
# CLEAN RULE:              #
# ************************ #
clean: down
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) clean rule!"
	#sudo rm -rf /home/$(USERNAME)/data/*
	#TODO:ls /home/$(USERNAME)/data/*



# ************************ #
# FCLEAN RULE:             #
# ************************ #
fclean: clean
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) fclean rule!"
#	docker rmi -f $(shell docker images -q nginx wordpress mariadb 2>/dev/null) || true
#	TODO



# ************************ #
# RE RULE:                 #
# ************************ #
re: fclean all
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) re rule!"

# ************************ #
# PS RULE:                 #
# ************************ #
ps:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) ps rule!"
	$(COMPOSE) ps
# ************************ #
# LOGS RULE:               #
# ************************ #
logs:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET)logs rule!"
	$(COMPOSE) logs -f


# ******************************************** #
# Declare all rules as PHONY (always executed) #
# ******************************************** #
.PHONY: all build up down clean fclean re ps logs
