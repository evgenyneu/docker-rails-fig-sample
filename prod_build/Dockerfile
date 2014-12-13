FROM ruby:2.1.5

RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD COPY Gemfile /usr/src/app/
ONBUILD COPY Gemfile.lock /usr/src/app/
ONBUILD RUN bundle install

ONBUILD COPY . /usr/src/app

# Installing common RoR dependencies: Node.js and database clients
# Remove the clients you don't use and modify to your needs.
RUN apt-get update && apt-get install -y --no-install-recommends nodejs && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends \
      mysql-client \
      postgresql-client \
      sqlite3 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3000
CMD ["rails", "server"]
