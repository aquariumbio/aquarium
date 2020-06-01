# Aquarium Development Guide

These guidelines are intended for those working directly on [Aquarium](aquarium.bio).

---

## Getting Started

1. Install [Docker](https://www.docker.com/get-started)

2. Get Aquarium using [git](https://git-scm.com) with the command

   ```bash
   git clone https://github.com/klavinslab/aquarium.git
   ```

## Running Aquarium

The following commands will allow you to run Aquarium in Rails development mode in a Unix&trade;-like environment.

1. **Build** the docker images with

   ```bash
   docker-compose build
   ```

2. **Start** Aquarium in development mode with

   ```bash
   docker-compose up
   ```

   In development mode, Aquarium is available at `localhost:3000`.

3. **Stop** the Aquarium services, type `ctrl-c` followed by

   ```bash
   docker-compose down -v
   ```

   Alternatively, you can run this command in a separate terminal within the `aquarium` directory .

## Working with an Aquarium Container

To run commands within the running Aquarium container, precede each command with

   ```bash
   docker-compose exec app
   ```

For instance, you can run the Rails console with the command

  ```bash
  docker-compose exec app rails c
  ```

And, you can also run an interactive shell within the Aquarium container with the command

   ```bash
   docker-compose exec app /bin/sh
   ```

which allows you to work within the container.

For commands that don't require that Aquarium is running, using a command starting with

   ```bash
   docker-compose run --rm app
   ```

will create a temporary container. 
This can be useful for running single commands such as

  ```bash
  docker-compose run --rm app rspec
  ```

which runs RSpec on the tests in the `spec` directory.

## Switching databases

The configuration for Docker uses the MySQL Docker image, which is capable of automatically importing a database dump the first time it is started.
You can switch the database, but doing so will destroy any changes you have made to the current database.
If you want to save these changes, you will have to create a database dump.

To make database dump, using the values of `MYSQL_USER` and `MYSQL_PASSWORD` from `.env` run the following

```bash
MYSQL_USER=<username>
MYSQL_PASSWORD=<password>
docker-compose up -d
docker-compose exec db mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD production > production_dump.sql
docker-compose down -v
```

You can then safely remove the MySQL files to allow the switch by running

```bash
rm -rf docker/db/*
```

Then copy the dump of the database that you want to use to the default location:

```bash
cp production_dump.sql docker/mysql_init/dump.sql
```

Note: It may be necessary to run migrations on database dump from a prior version of Aquarium.
See the Docker installation instructions at [aquarium.bio](aquarium.bio) for details.

## Restoring the default database dump

If you want to restart from an empty database, you can run

```bash
cp docker/mysql_init/default.sql docker/mysql_init/dump.sql
```

Before restarting Aquarium, remove the MySQL files with

```bash
rm -rf docker/db/*
```

## Testing Aquarium

### Running Tests

```bash
docker-compose run --rm app rspec
```

### Adding Tests

## Editing Aquarium

### Documenting changes

### Formatting Aquarium code

The Aquarium repository is setup to use [RuboCop](https://rubocop.readthedocs.io).

When you make changes to Aquarium code, run the command 

  ```bash
  docker-compose run --rm app rubocop -x
  ```

to fix layout issues.
Then run the command

  ```bash
  docker-compose run --rm app rubocop -x
  ```

to see if you have introduced any other issues.
This will check for several potential issues that occur in Rails apps.

You should fix any issues, but be certain to test them.
RuboCop can do other auto-corrections, but don't use that feature unless your tests ensure that the behavior is not changed.

Because RuboCop may change, it may be necessary to make changes to the `.rubocop.yml` file in the repository directory.
When the Ruby version is changed the target version in this file should also be changed.
Otherwise, you probably wont need to change this file.

### Fixing Style TODOs

The file `.rubocop_todo.yml` in the `aquarium` repository configures RuboCop so that it will ignore the listed issues when it processes the Ruby code in Aquarium.
This makes it possible for developers to focus on issues that they introduce when changing code.
However, it also identifies issues that we should try to eliminate.

The process of doing this is to pick one issue, fix it, test the fix, and then update the todo file.
When fixing issues make sure that there is a test that will exercise the fix, and be extra careful when applying auto-correct.
Some fixes may not be possible without affecting the Krill library for protocols, which could break protocols that are in use.

This command will regenerate the `.rubocop_todo.yml` file

  ```bash
  docker-compose run -rm app rubocop --auto-gen-config
  ```

### Documenting Aquarium Ruby Code

Aquarium Ruby methods and classes should be documented with [Yardoc](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md) regardless of whether they are public.

For instance, a function would be documented as

```ruby
# Display the instructions for centerfuging the given tubes.
#
# @param tubes [Array] the array of items representing tubes
def centerfuge_instructions(tubes)
  ...
end
```

unless a hash argument is used, in which case the comment would look like

```ruby
# Copy the data associations from the source item to the target item.
#
# @param args [Hash] the arguments indicating source and target items
# @option args [String] :source  the source item
# @option args [String] :target  the target item
def copy_associations(args)
  ...
end
```

Note that an argument with a default value is _not_ an option, and should just be listed using the `@param` tag.

Here are some ([borrowed](http://blog.joda.org/2012/11/javadoc-coding-standards.html)) style guidelines for documentation:

- Write your comments to be read from the source file.
  So, add formatting that is helpful to the programmer reading your code.
- The first sentence of the should be short, clear and to the point.
  Use the third person, e.g., "Returns the item ID for..."
- If documenting a class, use "this" to refer to an instance of the class.
- Aim for one (short) sentence per line.
  Each should end with a period.
- Use `@param` for all parameters, `@return` for return values, and `@raise` for exceptions raised.
  List these in that order.
- Put a single blank line after the first sentence, and then one after each paragraph.
  (If this doesn't give you a line before the first `@param` add one.)
- Write `@param` and `@raise` as a phrase starting with a lowercase letter and almost always the word "the", but with no period.
- Write `@raise` as a conditional phrase beginning with "if".
  Again, don't end the phrase with a period.

See also these yard [examples](https://gist.github.com/chetan/1827484)

The return value of a function should be documented using the `@return` tag, and any exception raised by a function should be documented with the `@raise` tag.
But, there are many more [tags](http://www.rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List) available, and you should feel free to use them.

Running the command

```bash
yardoc
```

will generate the documentation and write it to the directory `docs/api`.
This location is determined by the file `.yardopts` in the project repository.
This file also limits the API to code used in Krill the protocol development language.

### Updating Dependencies

```bash
docker-compose up -d
docker-compose exec app /bin/sh
bundle upgrade
docker-compose down -v
```

```bash
docker-compose up -d
docker-compose exec app /bin/sh
yarn update
docker-compose down -v
```

### Modifying this Document

This document is `docs/development/index.md` in the `aquarium` repository.
Keep it up-to-date if you change something that affects Aquarium development.

## Making an Aquarium Release

1.  Ensure that your clone is up to date

    ```bash
    git pull
    ```

2.  Build image to make sure that dependencies are up-to-date

    ```bash
    docker-compose build app
    ```

3.  Make sure Rails tests pass

    ```bash
    docker-compose up -d
    docker-compose exec app rspec
    docker-compose down -v
    ```

    If there are any failures, fix them and start over.

4.  Fix any layout problems 

    ```bash
    docker-compose run --rm app rubocop -x
    ```

5.  Run `rubocop`

    ```bash
    docker-compose run --rm app rubocop
    ```

    Fix any issues and start over.

5.  Update RuboCop TODO file

    ```bash
    docker-compose run -rm app rubocop --auto-gen-config
    ```

6.  (make sure JS tests pass)

7.  (Make sure JS linting passes)

8.  Update the version number in `package.json` and `config/initializers/version.rb` to the new version number.

9.  Update API documentation by running 

    ```bash
    docker-compose exec app yard
    ```

10. Update `CHANGE_LOG`

    ```bash
    git log v$OLDVERSION..
    ```

11. Ensure all changes have been committed and pushed.

    ```bash
    git status && git log --branches --not --remotes
    ```

    Commit and push any changes found.

12. Create a tag for the new version:

    ```bash
    git tag -a v$NEWVERSION -m "Aquarium version $NEWVERSION"
    git push --tags
    ```

13. [Create a release on github](https://help.github.com/articles/creating-releases/).
    Visit the [Aquarium releases page](https://github.com/klavinslab/aquarium/releases).
    - Click "Tags".
    - Click "add release notes" for the new tag, use the change log as the release notes.
    - Click "publish release".

14. (Update zenodo entry)

15. Push image to Docker Hub

    ```bash
    bash ./aquarium.sh build
    docker push aquariumbio/aquarium:v$NEWVERSION
    ```

## Aquarium Internals

## Aquarium Configuration

Aquarium is configured to run within Docker using the following files:

```bash
aquarium
|-- docker
|   |-- db                        # directory to store database files
|   |-- mysql_init                # database dump to initialize database
|   |-- s3                        # directory for minio files
|   |-- aquarium-entrypoint.sh    # entrypoint for running Aquarium
|   |-- krill-entrypoint.sh       # entrypoint for running Krill
|   |-- nginx.development.conf    # nginx configuration for development server
|   `-- nginx.production.conf     # nginx configuration for production server
|-- docker-compose.override.yml   # development compose file
|-- docker-compose.production.yml # production compose file
|-- docker-compose.windows.yml    # windows compose file
|-- docker-compose.yml            # base compose file
`-- Dockerfile                    # defines the image for Aquarium
```

### Images

The `Dockerfile` configures the `basebuilder` Aquarium image that contains the configuration needed by development or production environments.

The `basebuilder` image is based on the Ruby Alpine linux Docker image that includes Rails.
In addition the image includes:

1. Development tools needed to configure and run Aquarium.
2. Javascript components used by Aquarium webpages.
3. Gems used by Aquarium.
4. The `aquarium` application (minus the files in `.dockerignore`).
5. The entrypoint scripts for running Aquarium and Krill from Docker.

Note that this base configuration includes the configuration files in `config`, though the docker-compose configurations override these.

copies rails configuration files from the `docker/aquarium` directory into the correct place in the image; and adds the `docker/aquarium-entrypoint.sh` and `docker/krill-entrypoint.sh` scripts for starting the Aquarium services.
The configuration also ensures that the `docker/db` and `docker/s3` directories needed for the database and [minio](https://minio.io) S3 server are created on the host as required by the compose files.
The `devbuilder` and `prodbuilder` configurations build an image with environment specific files.

### Compose files

The docker-compose files are defined to allow Aquarium to be run locally in production or development modes and on Windows.

Specifically, the files are meant to be combined as follows:

- `docker-compose.yml` and `docker-compose.override.yml` runs production,
- `docker-compose.yml` and `docker-compose.dev.yml` runs development, and
- adding `docker-compose.windows.yml` allows MySQL to run on Windows.

The order of the files is significant since the later files add or replace definitions from the base file.

Note that the command for the first combination

```bash
docker-compose -f docker-compose.yml -f docker-compose.override.yml up
```

is equivalent to the simpler command

```bash
docker-compose up
```

The compose files are designed so that running in production is the default configuration to support users who are doing protocol development on a local instance.
To support this, the `docker-compose.yml` file contains the common configuration for both environments, including identifying the entrypoints for Aquarium and Krill, mounting host directories used by Aquarium, MySQL and minio for persistent storage.
The file `docker-compose.override.yml` is run by default and adds production environment files to the base configuration, while `docker-compose.dev.yml` adds the configurations for the development environment.

Much of the key differences between environments are handled by mounting different files with the different configurations.
For instance, the Rails configuration files are replaced by files from `docker/aquarium` that are mounted over the counterparts in `config`.
In the case of configuring MySQL and nginx, the mount points for the configuration files are particular to the image used for these services, some of which are not terribly well documented.
Using volumes in this way is convenient, but can also be the source of great mystery when a mounted volume overrides the files in the image.
Tweak the volumes with care.

### Database

The `docker/mysql_init` directory contains the database dump that is used to initialize the database when it is run the first time.
The MySQL service is configured to use the `docker/db` directory to store its files, and removing the contents of this directory (`rm -rf docker/db/*`) will cause the database to initialize the next time the service is started.

### Local S3 server

A [minio](minio.io) service `s3` is used to manage files uploaded to Aquarium in the local configuration.
The `s3` service is configured so that these files are stored in `docker/s3`.
The current configuration does not allow the pre-signed URLs returned by Aquarium to be used because the host is configured to be the hostname of the service, which is only accessible from within Docker.
However, the files are also be accessible through the minio webclient at `localhost:9000`.

### Local web server

Access to Aquarium and the S3 webclient is handled by nginx.
For development, all requests to port 3000 are forwarded to Aquarium, while for production, static files are served by nginx and other requests are handled by puma via a socket.
See the nginx configuration files in the `docker` directory.
