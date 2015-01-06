#!/bin/bash

REGISTRY_PORT="8080"

####################
# System variables #
####################

REDIS_IMAGE_NAME="redis"
REDIS_CONTAINER_NAME="registry-redis"

DOCKER_IMAGE_NAME="registry-docker"
DOCKER_CONTAINER_NAME="registry-docker"
DOCKER_PATH_TO_DOCKERFILE="registry-docker"
DOCKER_DATA_DIR="data"
DOCKER_CONF_DIR="registry-docker/conf"
DOCKER_DB_DIR="db"

NGINX_IMAGE_NAME="registry-nginx"
NGINX_CONTAINER_NAME="registry-nginx"
NGINX_PATH_TO_DOCKERFILE="registry-nginx"

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###########
# Helpers #
###########

echo_delimiter()
{
    echo "--------------------------------------"
    echo
}

help_commands()
{
    echo "Please, specify command:"
    echo "  help   -- view full help message"
    echo "  build  -- build docker images"
    echo "  start  -- run docker containers"
    echo "  stop   -- stop docker containers"
    echo "  attach -- attach to docker registry"
    echo "  logs   -- see docker registry logs"
    echo "  rm     -- stop and remove docker containers"
    echo "  rmi    -- remove docker images"
}

help_message()
{
    echo "#########"
    echo "# Usage #"
    echo "#########"
    echo "Use this script to build and deploy secure and persistent"
    echo "private Docker registry:"
    echo "  $0 build -- build docker containers for Redis, Docker and Nginx"
    echo "  $0 start -- start registry"
    echo
    echo "Docker images, served by registry, stored in data/ directory."
    echo "Docker system database, used for indexing, stored in db/ directory."
    echo
    echo "################"
    echo "# Certificates #"
    echo "################"
    echo "To use your own ssl keys, simple replace ssl/registry-docker.crt,"
    echo "ssl/registry-docker.key with your signed keys."
    echo
    echo "After that you should add certificate authority to system certificates"    
    echo "ON ALL MACHINES, which will use your private repo."
    echo
    echo "To do this, copy ssl/CA.crt or your own certificate to"
    echo "/etc/ssl/certs/registry-docker.crt, then run sudo update-ca-certificates" 
    echo "and restart docker."
}

###################
# Redis utilities #
###################

redis_pull()
{
    echo "Pulling Redis from docker.io...";
    docker pull redis;
    echo_delimiter;
}

redis_start()
{
    echo "Starting Redis container...";
    docker run -d --name ${REDIS_CONTAINER_NAME} redis;
    echo_delimiter;
}

redis_stop()
{
    echo "Stopping Redis container...";
    docker stop ${REDIS_CONTAINER_NAME};
    echo_delimiter;
}

redis_rm()
{
    echo "Removing Redis container...";
    docker rm ${REDIS_CONTAINER_NAME};
    echo_delimiter;
}

redis_rmi()
{
    echo "Removing Redis image...";
    docker rmi ${REDIS_IMAGE_NAME};
    echo_delimiter;
}

####################
# Docker utilities #
####################

docker_build()
{
    echo "Building Docker registry image...";
    docker build -t="${DOCKER_IMAGE_NAME}" ${PWD}/${DOCKER_PATH_TO_DOCKERFILE};
    echo_delimiter;
}

docker_start()
{
    echo "Starting Docker registry container...";
    docker run \
    -d \
    --name ${DOCKER_CONTAINER_NAME} \
    --link ${REDIS_CONTAINER_NAME}:redis \
    -v ${PWD}/${DOCKER_DATA_DIR}:/registry/data \
    -v ${PWD}/${DOCKER_CONF_DIR}:/registry/conf \
    -v ${PWD}/${DOCKER_DB_DIR}:/registry/sqlitedb \
    ${DOCKER_IMAGE_NAME};
    echo_delimiter;
}

docker_stop()
{
    echo "Stopping Docker registry container...";
    docker stop ${DOCKER_CONTAINER_NAME};
    echo_delimiter;
}

docker_logs()
{
    echo "Logging to Docker registry container..."
    docker logs -f ${DOCKER_CONTAINER_NAME};
}

docker_attach()
{
    echo "Attaching to Docker registry container..."
    docker attach ${DOCKER_CONTAINER_NAME};
}

docker_rm()
{
    echo "Removing Docker registry container...";
    docker rm ${DOCKER_CONTAINER_NAME};
    echo_delimiter;
}

docker_rmi()
{
    echo "Removing Docker registry image...";
    docker rmi ${DOCKER_IMAGE_NAME};
    echo_delimiter;
}

###################
# Nginx utilities #
###################

nginx_build()
{
    echo "Building Nginx image...";
    docker build -t="${NGINX_IMAGE_NAME}" ${PWD}/${NGINX_PATH_TO_DOCKERFILE};
    echo_delimiter;
}

nginx_start()
{
    echo "Starting nginx container...";
    docker run \
    -d \
    --name ${NGINX_CONTAINER_NAME} \
    --link ${DOCKER_CONTAINER_NAME}:registry-docker \
    -v ${PWD}/ssl:/etc/nginx/ssl \
    -p 8080:${REGISTRY_PORT} \
    ${NGINX_IMAGE_NAME};
    echo_delimiter;
}

nginx_stop()
{
    echo "Stopping nginx container...";
    docker stop ${NGINX_CONTAINER_NAME};
    echo_delimiter;
}

nginx_rm()
{
    echo "Removing nginx container...";
    docker rm ${NGINX_CONTAINER_NAME};
    echo_delimiter;
}

nginx_rmi()
{
    echo "Removing nginx image...";
    docker rmi ${NGINX_IMAGE_NAME};
    echo_delimiter;
}

####################
# Common functions #
####################

all_start()
{
    echo "Starting containers..."
    redis_start;
    docker_start;
    nginx_start;
}

all_stop()
{
    echo "Stopping containers..."
    nginx_stop;
    docker_stop;
    redis_stop;    
}

all_rm()
{
    echo "Removing containers..."
    nginx_rm;
    docker_rm;
    redis_rm;
}

all_rmi()
{
    echo "Removing images..."
    nginx_rmi;
    docker_rmi;
    redis_rmi;
}

###############
# Script body #
###############

if [[ "$1" == "help" ]]
then
    help_message;
    exit 0;
fi

if [[ "$1" == "build" ]]
then
    echo "Building containers..."
    redis_pull;
    docker_build;
    nginx_build;
    exit 0;
fi

if [[ "$1" == "start" ]]
then
    all_start;
    exit 0;
fi

if [[ "$1" == "stop" ]]
then
    all_stop;
    exit 0;
fi

if [[ "$1" == "logs" ]]
then
    docker_logs;
    exit 0;
fi

if [[ "$1" == "attach" ]]
then
    docker_attach;
    exit 0;
fi

if [[ "$1" == "rm" ]]
then
    all_rm;
    exit 0;
fi

if [[ "$1" == "rmi" ]]
then
    all_rmi;
    exit 0;
fi

###################
# Unknown command #
###################

help_commands;
exit 1;
