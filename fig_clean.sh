#!/usr/bin/env bash

# Removes containers and images for the app. Keeps the database and gems containers

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

# Remove an image by name.
# Usage: remove_image_by_name IMAGE_NAME
remove_image_by_name(){
  docker images -a | grep $1 | awk '{ print $3 }' | xargs docker rmi
}

stop_container_by_name $FIG_PREFIX
remove_container_by_name $FIG_PREFIX
remove_image_by_name $FIG_PREFIX
