# Using Rails/Postgres with Docker and Fig

This is a demo Rails app with Docker. It creates development environment and scripts for deployment to production.

This repository is based on [https://github.com/whitesmith/rails-pg-fig-sample](https://github.com/whitesmith/rails-pg-fig-sample).

## Installation

1. Install [Docker](https://www.docker.com/) and [Fig](http://www.fig.sh).
1. Run `./scripts/init_development.sh` to create development environment.
1. Run `fig up` to start rails web server.
1. Open `http://localhost:3000/` in the web browser. On Mac OS, run `boot2docker ip` command to get the IP address.

***`fig stop`*** - stops the app.
***`fig rm`*** - removes the app containers.

## How it works

### Rails app docker image

It creates a docker image for the Rails app called `web`.
It is configured to keep the source code on developer host and not in the image.
It allows to make changes to the source code and see results in the browser.

### Docker containers

Following docker containers are created:

1. **Web** for Rails app.
1. **DB** for Postgres DB server.
1. **iipersist-db-data** is a [Data Volume Container](https://docs.docker.com/userguide/dockervolumes/) for the database storage.
1. **iipersist-gems-2.1** is another Data Volume Container for the gems.

## Deploying to production

(Work in progress)

### 1. Create a deployment image

`./script/docker_create_deploy_image.sh myaccount/image`

Use your Docker Hub account name and deployment image name. The single purpose of this step is to create an image that contains app's source code. You may want to make this repository private.

### 2. Push the image to Docker Hub

`docker push myaccount/image`

### 3. Copy fig_production.yml

1. In `fig_production.yml` replace `myaccount/image` with correct account and image.
1. Copy `fig_production.yml` to `fig.yml` on your production host.
1. Use docker_upload_data_volume_container.sh to upload database files and Gems to your server:

```
./scripts/docker_upload_data_volume_container.sh iipersist-gems-2.1 /usr/local/bundle myserver.com
./scripts/docker_upload_data_volume_container.sh iipersist-db-data /var/lib/postgresql/data myserver.com
```

### 4. Create production environment

Finally, run `fig up` on your production host.

## Scripts

Scripts are located in `scripts` directory.

### fig_remove_containers.sh

Cleanup script that removes containers for the app. It does not remove the database and gems containers.
This script can be run after `fig stop` and `fig rm`.


### docker_data_volume_container_backup.sh

Backup data from data volume container into a tar.gz file in the current directory.

__Usage:__

`docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH`

__Example:__

`./docker_data_volume_container_backup.sh iipersist-db-data /var/lib/postgresql/data`


### docker_data_volume_container_restore.sh

Restore data from CONTAINER_NAME.tar.gz into a data volume container.

__Usage:__

`docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH`

__Example:__

Restore iipersist-db-data.tar.gz into iipersist-db-data Data Volume Container:

`./docker_data_volume_container_restore.sh iipersist-db-data /var/lib/postgresql/data`


### docker_upload_data_volume_container.sh

This script uploads data volume container to a remote host.

The job includes the following steps:

1. It archives a local data volume container.
1. Copies the archive to remote host.
1. Restores the archive into the data volume container on remote host.

__Usage:__

`docker_upload_data_volume_container.sh CONTAINER_NAME VOLUME_PATH HOST_SSH_ADDRESS`

__Example:__

Uploads iipersist-db-data Data Volume Container to myserver.com host.

`./docker_upload_data_volume_container.sh iipersist-db-data /var/lib/postgresql/data myserver.com`

## Reference

Resources that helped me with this project:

* [Dockerizing Applications: A "Hello world"](https://docs.docker.com/userguide/dockerizing/)

* [How to Create a Persistent Ruby Gems Container with Docker](http://www.atlashealth.com/blog/2014/09/persistent-ruby-gems-docker-container/)

* [Orchestrating Docker containers in production using Fig](http://blog.docker.com/2014/08/orchestrating-docker-containers-in-production-using-fig/)

* [A Rails development environment using Docker through Fig](http://www.whitesmith.co/blog/a-rails-development-environment-using-docker-through-fig/)

## Feedback welcome

Feel free to create an issue ticket. Or if you are stuck and need help please do not hesitate to ask.



