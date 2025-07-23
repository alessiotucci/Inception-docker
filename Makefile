# **************************************************************************** #
#                                                                              #
#    Host: e4r2p4.42roma.it                                           /_/      #
#    File: Makefile                                                ( o.o )     #
#    Created: 2025/07/12 17:34:26 | By: atucci <atucci@student.42  > ^ <       #
#    Updated: 2025/07/23 08:43:36                                   /          #
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
all: check-docker build up
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) default"
	@echo "$(GREEN) building and starting the containers -> build -> up $(RESET)"

# ****************************************** #
# CHECK RULE: write a nice ascii and checks  #
# ****************************************** #
check-docker:
	@command -v docker >/dev/null 2>&1 || { \
		echo "Error: Docker is not installed. Please install Docker."; \
		exit 1; \
	}
	@command -v docker-compose >/dev/null 2>&1 || { \
		echo "Error: docker-compose is not installed. Please install Docker Compose."; \
		exit 1; \
	}
	@printf "$(CYAN)%s\n" \
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣾⣷⣶⣦⣄⠀⠀⠀" \
	"⠀⠀⠀⠀⠀⠀⠀⣠⣾⡇⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀" \
	"⢀⣀⣀⣀⣠⣴⣾⣿⣿⠃⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆" \
	"⠈⠻⢿⣿⣿⣿⡿⣟⠃⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧" \
	"⠀⠀⠀⠀⠈⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣼⣿⣿⣿⣿⣿⣿⠇" \
	"⠀⠀⠀⠀⠀⠀⠀⠈⠙⢻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⡙⠛⢛⡻⠋⠀" \
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠒⠄⠬⢉⣡⣠⣿⣿⣿⣇⡌⠲⠠⠋⠈⠀⠀⠀" \
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" \
	"  _____                      _   _             " \
	" |_   _|                    | | (_)            " \
	"   | |  _ __   ___ ___ _ __ | |_ _  ___  _ __  " \
	"   | | | '_ \ / __/ _ \ '_ \| __| |/ _ \| '_ \ " \
	"  _| |_| | | | (_|  __/ |_) | |_| | (_) | | | |" \
	" |_____|_| |_|\___\___| .__/ \__|_|\___/|_| |_|" \
	"                       | |                      " \
	"                       |_|                      "

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
	sudo rm -rf /home/$(USERNAME)/data/*



# ************************ #
# FCLEAN RULE:             #
# ************************ #
fclean: clean ps
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) fclean rule!"
	@docker rmi -f $$(docker images -q) || true



# ************************ #
# RE RULE:                 #
# ************************ #
re: fclean all
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET) re rule!"

# ******** #
# PS RULE: #
# ******** #
ps:
	@echo "$(GREEN)==> $(USERNAME): $(PROJECTNAME) – docker ps -a$(RESET)"
	@docker ps -a
	@echo "$(GREEN)==> $(USERNAME): $(PROJECTNAME) – docker images -a$(RESET)"
	@docker images -a

# ************************ #
# LOGS RULE:               #
# ************************ #
logs:
	@echo "$(GREEN) $(USERNAME):\t$(PROJECTNAME) $(RESET)logs rule!"
	$(COMPOSE) logs -f


# ******************************************** #
# Declare all rules as PHONY (always executed) #
# ******************************************** #
.PHONY: all build up down clean fclean re ps logs check-docker
