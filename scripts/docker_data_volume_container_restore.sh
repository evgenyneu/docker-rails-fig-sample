#!/usr/bin/env bash

# Restore data from tar.gz into a data volume container.
# Usage: docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH

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

CONTAINER_NAME=$1
VOLUME_PATH=$2

if [ -n "$(docker ps -a | grep $CONTAINER_NAME)" ]; then
  print_success "The data container ($CONTAINER_NAME) already exists."
else
  docker run -d -v $VOLUME_PATH --name $CONTAINER_NAME tianon/true
  handle_error $? "creating data volume container"

  docker run --rm --volumes-from $CONTAINER_NAME -v $(pwd):/backup ubuntu tar xvzf /backup/$CONTAINER_NAME.tar.gz
  handle_error $? "restoring archive into data volume container"

  print_normal
  print_success "Archive $CONTAINER_NAME.tar.gz is restored in $CONTAINER_NAME container"
fi

exit 0


