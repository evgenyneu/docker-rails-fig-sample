#!/usr/bin/env bash

# Removes containers for the app. Keeps the database and gems containers

FIG_PREFIX=$(echo ${PWD##*/} | tr -d '-')

# Stop a container by name.
# Usage: stop_container_by_name CONTAINER_NAME
stop_container_by_name(){
  docker ps -a | grep $1 | awk '{ print $1 }' | xargs docker stop
}

# Remove a container by name.
# Usage: remove_container_by_name CONTAINER_NAME
remove_container_by_name(){
  docker ps -a | grep $1 | awk '{ print $1 }' | xargs docker rm
}

stop_container_by_name $FIG_PREFIX
remove_container_by_name $FIG_PREFIX
