# Using Rails/Postgres with Docker and Fig

This repository is a sample Rails app. It uses Docker to keep its compenents in separate containers.
This repository is based on [https://github.com/whitesmith/rails-pg-fig-sample](https://github.com/whitesmith/rails-pg-fig-sample).

## Installation

1. Install [Docker](https://www.docker.com/) and [Fig](http://www.fig.sh).
1. Run `./init_development.sh` to create development environment.
1. Run `fig up` to start rails web server.

### Other useful commands

***`fig stop`*** - stops the app.
***`fig rm`*** - removes the app containers.

## How it works

### Rails app docker image

It creates one docker image caleld `web`. This is rails image.
It is configured to keep rails app source code on developer host and not in the image.
This way one can make changes to the source code and see results in the browser immediatelly.

### Docker containers

Following docker containers are created:

1. **Web** for Rails app
1. **DB** for Postres DB server
1. **iipersist-db-data** is a [Data Volume Container](https://docs.docker.com/userguide/dockervolumes/) for database
1. **iipersist-gems-2.1** is another Data Volume Container for the gems.

## Deploying to production

(Work in progress)

## Scripts

Scripts are located in `scripts` directory.

### fig_remove_containers.sh

Cleanup script that removes containers for the app. Keeps the database and gems containers.
This script can be run after `fig stop` and `fig rm`.


### docker_data_volume_container_backup.sh

Backup data from data volume container into a tar.gz file in the current directory.

Usage:

`docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH`

Example:

`./docker_data_volume_container_backup.sh iipersist-db-data /var/lib/postgresql/data`


### docker_data_volume_container_restore.sh

Restore data from CONTAINER_NAME.tar.gz into a data volume container.

Usage:

`docker_data_volume_container_backup.sh CONTAINER_NAME VOLUME_PATH`

Example:

Restore iipersist-db-data.tar.gz into iipersist-db-data Data Volume Container:

`./docker_data_volume_container_restore.sh iipersist-db-data /var/lib/postgresql/data`


### docker_upload_data_volume_container.sh

This script uploads data volume container to a remote host.

The job includes the following steps:

1. It archives a local data volume container.
1. Copies the archive to remote host.
1. Restores the archive into the data volume container on remote host.

Usage:

`docker_upload_data_volume_container.sh CONTAINER_NAME VOLUME_PATH HOST_SSH_ADDRESS`

Example:

Uploads iipersist-db-data Data Volume Container to myserver.com host.

`./docker_upload_data_volume_container.sh iipersist-db-data /var/lib/postgresql/data myserver.com`




