# Using Rails/Postgres with Docker and Fig

This repository is a sample Rails app. It uses Docker to keep its compenents in separate containers.
This repository is based on [https://github.com/whitesmith/rails-pg-fig-sample](https://github.com/whitesmith/rails-pg-fig-sample).

## Installation

1. Install [Docker](https://www.docker.com/) and [Fig](http://www.fig.sh).
1. Run `./init_development.sh` to create development environment.
1. Run `fig up` to start rails web server.

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



