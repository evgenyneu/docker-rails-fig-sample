#!/usr/bin/env bash

# Backup data from data volume container into a tar.gz file in the current directory.
# Usage: docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH

print_info(){ printf "$(tput setaf 3)%b$(tput sgr0)\n" "$1" >&2; }

CONTAINER_NAME=$1
VOLUME_PATH=$2

docker run --rm --volumes-from $CONTAINER_NAME -v $(pwd):/backup ubuntu tar czvf /backup/$CONTAINER_NAME.tar.gz $VOLUME_PATH

print_info "Data is archived into $CONTAINER_NAME.tar.gz"

