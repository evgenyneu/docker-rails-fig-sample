#!/usr/bin/env bash

APP_NAME=iiapp
DB_DATA_CONTAINER_NAME=$APP_NAME-db-data
DOCKER_MINIMAL_IMAGE=tianon/true
DEV_FIG_YML=fig_development.yml

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

# Build containers
bootstrap(){
  print_info "Bootstrapping $APP_NAME"

  create_data_container_if_not_exists $DB_DATA_CONTAINER_NAME "/var/lib/postgresql/data/"

  # Build the web container
  print_info "Building the web container."
  fig build web
  handle_error $? "building the web container"

  # Install bundler
  # print_info "Installing bundler."
  # fig run web gem install bundler
  # handle_error $? "installing bundler"

  print_info "Bundle install"
  fig run web bundle install --jobs 4 --retry 3
  handle_error $? "installing the app's dependencies"
}

bootstrap

exit 0
