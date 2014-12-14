#!/usr/bin/env bash

# This script does following steps:
#   1. It archives a local data volume container/
#   2. Copies the archive to remote host.
#   3. Restores the archive into the data volume container on remote host.
# Usage: docker_data_volume_container_backup_and_restore.sh CONTAINER_NAME VOLUME_PATH HOST_SSH_ADDRESS

# Fancy prints
print_normal (){ printf "%b\n" "$1" >&2; }
print_error  (){ printf "$(tput setaf 1)%b$(tput sgr0)\n" "$1" >&2; }
print_info   (){ printf "$(tput setaf 3)%b$(tput sgr0)\n" "$1" >&2; }
print_success(){ printf "$(tput setaf 2)%b$(tput sgr0)\n" "$1" >&2; }

# Abort in the case of an error
handle_error(){
  if [ $1 -ne 0 ]; then
    print_error "Something went wrong while $2, aborting."
    exit 1
  fi
}

CONTAINER_NAME=$1
VOLUME_PATH=$2
HOST_SSH_ADDRESS=$3

ARCHIVE_FILE_NAME=$CONTAINER_NAME.tar.gz
BACKUP_DIR=backups

if [ -n "$(ssh $HOST_SSH_ADDRESS \"sudo docker ps -a | grep $CONTAINER_NAME\")" ]; then
  print_error "The data container ($CONTAINER_NAME) already exists. Please remove it first on remote host $HOST_SSH_ADDRESS"
else
  ./scripts/docker_data_volume_container_backup.sh $CONTAINER_NAME $VOLUME_PATH
  handle_error $? "archiving container $CONTAINER_NAME"

  ssh $HOST_SSH_ADDRESS "mkdir -p ~/$BACKUP_DIR"
  handle_error $? "creating backups directory on $HOST_SSH_ADDRESS"

  print_info "Copying $ARCHIVE_FILE_NAME to $HOST_SSH_ADDRESS"
  scp $ARCHIVE_FILE_NAME $HOST_SSH_ADDRESS:~/$BACKUP_DIR/.
  handle_error $? "copying $ARCHIVE_FILE_NAME to $HOST_SSH_ADDRESS"

  rm $ARCHIVE_FILE_NAME
  handle_error $? "removing $ARCHIVE_FILE_NAME"

  ssh $HOST_SSH_ADDRESS "cd $BACKUP_DIR; sudo bash -s" < ./scripts/docker_data_volume_container_restore.sh $CONTAINER_NAME $VOLUME_PATH
  handle_error $? "restoring data volume container $CONTAINER_NAME on $HOST_SSH_ADDRESS from archive ~/$BACKUP_DIR/$ARCHIVE_FILE_NAME"

  print_normal
  print_success "Data container $CONTAINER_NAME successfully copied to remote host $HOST_SSH_ADDRESS"

  exit 0
fi