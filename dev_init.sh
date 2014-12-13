#!/usr/bin/env bash

# Fancy prints
print_normal (){ printf "%b\n" "$1" >&2; }
print_error  (){ printf "$(tput setaf 1)[fig-tree] %b$(tput sgr0)\n" "$1" >&2; }
print_info   (){ printf "$(tput setaf 3)[fig-tree] %b$(tput sgr0)\n" "$1" >&2; }
print_success(){ printf "$(tput setaf 2)[fig-tree] %b$(tput sgr0)\n" "$1" >&2; }

# Abort in the case of an error
handle_error(){
  if [ $1 -ne 0 ]; then
    print_error "Something went wrong while $2, aborting."
    exit 1
  fi
}

APP_NAME=iiapp
DB_DATA_CONTAINER_NAME=$APP_NAME-db-data
DOCKER_MINIMAL_IMAGE=tianon/true

# `docker info` call for testing if the Docker host is reachable.
# Usage: check_docker
check_docker(){
  docker info > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    print_error "ERROR: Docker host could not be reached. Maybe you need sudo?"
    exit 1
  fi
}

# Stop a container by name.
# Usage: stop_container_by_name CONTAINER_NAME
stop_container_by_name(){
  docker ps -a | grep $1 | awk '{ print $1 }' | xargs --no-run-if-empty docker stop
}

# Remove a container by name.
# Usage: remove_container_by_name CONTAINER_NAME
remove_container_by_name(){
  docker ps -a | grep $1 | awk '{ print $1 }' | xargs --no-run-if-empty docker rm
}

# Remove an image by name.
# Usage: remove_image_by_name IMAGE_NAME
remove_image_by_name(){
  docker images -a | grep $1 | awk '{ print $3 }' | xargs --no-run-if-empty docker rmi
}


# Create a data volume container for a specific path.
# Usage: create_data_container CONTAINER_NAME VOLUME_PATH
create_data_container(){
  docker run -d --name $1 -v $2 $DOCKER_MINIMAL_IMAGE
}

# Create a data volume container for a specific path if it does not exist
# Usage: create_data_container CONTAINER_NAME VOLUME_PATH
create_data_container_if_not_exists(){
  # Check if the database data container already exists. If not, create it.
  if [ -n "$(docker ps -a | grep $DB_DATA_CONTAINER_NAME)" ]; then
    print_success "The database data container ($DB_DATA_CONTAINER_NAME) already exists."
  else
    print_info "Creating the database data container ($DB_DATA_CONTAINER_NAME)."
    create_data_container $1 $2
    handle_error $? "creating $DB_DATA_CONTAINER_NAME"
    print_success "Database data container ($DB_DATA_CONTAINER_NAME) successfully created."
  fi
}

bootstrap(){
  create_data_container_if_not_exists $DB_DATA_CONTAINER_NAME "/var/lib/postgresql/data/"

  # Build the web container
  print_info "Building the web container."
  fig build web
  handle_error $? "building the web container"
}

case "$1" in
  "bootstrap")
    bootstrap
  ;;

  *)
    print_normal "Usage: $0 COMMAND"
    print_normal
    print_normal "Available commands:"
    print_normal "  bootstrap"
  ;;
esac

exit 0
