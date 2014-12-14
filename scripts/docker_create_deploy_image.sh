#!/usr/bin/env bash

# Creates a docker image for deployment. The app srouce code is copied into the image.
#
# Usage:
#   docker_create_deploy_image.sh

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


# Swaps two dockerfiles
# Usage: swap_dockerfiles Dockerfile_deployment Dockerfile_development
swap_dockerfiles(){
  mv Dockerfile $2
  handle_error $? "moving Dockerfile"

  mv $1 Dockerfile
  handle_error $? "moving Dockerfile"
}

DEPLOYMENT_DOCKERFILE=Dockerfile_deployment
DEVELOPMENT_DOCKERFILE=Dockerfile_development
DEPLOYMENT_IMAGE_NAME=evgenyneu/rails_prod

swap_dockerfiles $DEPLOYMENT_DOCKERFILE $DEVELOPMENT_DOCKERFILE

docker build -t DEPLOYMENT_IMAGE_NAME .

swap_dockerfiles $DEVELOPMENT_DOCKERFILE $DEPLOYMENT_DOCKERFILE

print_normal
print_success "Successfully build deployment image $DEPLOYMENT_IMAGE_NAME"

exit 0