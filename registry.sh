#!/bin/bash

REGISTRY_PORT="8080"

####################
# System variables #
####################

REDIS_CONTAINER_NAME="registry-redis"

DOCKER_IMAGE_NAME="registry-docker"
DOCKER_CONTAINER_NAME="registry-docker"
DOCKER_PATH_TO_DOCKERFILE="registry-docker"
DOCKER_DATA_DIR="registry-docker/data"
DOCKER_CONF_DIR="registry-docker/conf"
DOCKER_DB_DIR="registry-docker/sqlitedb"

NGINX_IMAGE_NAME="registry-nginx"
NGINX_CONTAINER_NAME="registry-nginx"
NGINX_PATH_TO_DOCKERFILE="registry-nginx"

PWD="$(pwd)"


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
    echo "  help  -- view full help message"
    echo "  build -- build docker containers"
    echo "  start -- run docker containers"
    echo "  stop  -- stop docker containers"
    echo "  rm    -- remove docker containers"
}

help_message()
{
    echo "Use this script to build and deploy secure and persistent"
    echo "private Docker registry:"
    echo "  $0 build"
    echo "  $0 start"
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

####################
# Docker utilities #
####################

docker_build()
{
    echo "Building Docker registry...";
    docker build -t="${DOCKER_IMAGE_NAME}" ${DOCKER_PATH_TO_DOCKERFILE};
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

docker_rm()
{
    echo "Removing Docker registry container...";
    docker rm ${DOCKER_CONTAINER_NAME};
    echo_delimiter;
}

###################
# Nginx utilities #
###################

nginx_build()
{
    echo "Building Nginx container...";
    docker build -t="${NGINX_IMAGE_NAME}" ${NGINX_PATH_TO_DOCKERFILE};
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


###############
# script body #
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
    echo "Starting containers..."
    redis_start;
    docker_start;
    nginx_start;
    exit 0;
fi

if [[ "$1" == "stop" ]]
then
    echo "Stopping containers..."
    nginx_stop;
    docker_stop;
    redis_stop;
    exit 0;
fi

if [[ "$1" == "rm" ]]
then
    echo "Removing containers..."
    nginx_rm;
    docker_rm;
    redis_rm;
    exit 0;
fi


###################
# Unknown command #
###################

help_commands;
exit 1;
