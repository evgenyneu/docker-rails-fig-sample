#!/usr/bin/env bash

APP_NAME=iiapp

DOCKER_MINIMAL_IMAGE=tianon/true
DB_DATA_CONTAINER_NAME=$APP_NAME-db-data

RUBY_VERSION=2.1
GEMS_CONTAINER_NAME=$APP_NAME-gems-$RUBY_VERSION

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
# Usage: create_data_container_if_not_exists CONTAINER_NAME VOLUME_PATH
create_data_container_if_not_exists(){
  # Check if the database data container already exists. If not, create it.
  if [ -n "$(docker ps -a | grep $1)" ]; then
    print_success "The data container ($1) already exists."
  else
    print_info "Creating the database data container ($1)."
    create_data_container $1 $2
    handle_error $? "creating $1"
    print_success "Data container ($1) successfully created."
  fi
}

# Runs bundle install
# Usage: install_bundler_if_needed GEMS_CONTAINER
install_bundler_if_needed(){
  # Check if the gems container was just created; if so, install bundler.
  if [ -z "$1" ]; then
    print_info "Gems container is new, installing bundler."
    fig run web gem install bundler
    handle_error $? "installing bundler"
  else
    print_info "Gems container already existed before this script: assuming bundler is already installed."
    print_info "In the case of failure, run"
    print_info "  fig run web gem install bundler"
    print_info "and re-run this script."
  fi
}

# Build containers
bootstrap(){
  print_info "Bootstrapping $APP_NAME"

  local GEMS_CONTAINER=$(docker ps -a | grep $GEMS_CONTAINER_NAME)
  print_info "Creating the gems container for Ruby $RUBY_VERSION ($GEMS_CONTAINER_NAME)."
  create_data_container_if_not_exists $GEMS_CONTAINER_NAME "/usr/local/bundle"

  print_info "Creating the database data container ($DB_DATA_CONTAINER_NAME)."
  create_data_container_if_not_exists $DB_DATA_CONTAINER_NAME "/var/lib/postgresql/data/"

  # Build the web container
  print_info "Building the web container."
  fig build web
  handle_error $? "building the web container"

  # Install bundler
  install_bundler_if_needed $GEMS_CONTAINER

  # Bundle install
  print_normal
  print_info "Bundle install"
  fig run web bundle install --jobs 4 --retry 3
  handle_error $? "installing the app's dependencies"

  # Setup database
  print_info "Setting up the database (rake db:setup)"
  fig run web rake db:setup
  handle_error $? "setting up the database"

  print_normal
  print_success "The project was successfully setup! "
  print_success "Run 'fig up' to start the server."
}

bootstrap

exit 0
