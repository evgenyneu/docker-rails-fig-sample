#!/usr/bin/env bash

# Backup data from data volume container into a tar.gz file in the current directory.
# Usage: docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH

print_info(){ printf "$(tput setaf 3)%b$(tput sgr0)\n" "$1" >&2; }
print_error  (){ printf "$(tput setaf 1)[fig-tree] %b$(tput sgr0)\n" "$1" >&2; }
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

docker run --rm --volumes-from $CONTAINER_NAME -v $(pwd):/backup ubuntu tar czvf /backup/$CONTAINER_NAME.tar.gz $VOLUME_PATH
handle_error $? "archiving data volume container"

print_success "Data is archived into $CONTAINER_NAME.tar.gz"

