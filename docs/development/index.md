# Aquarium Development Guide

These guidelines are intended for those working directly on the [Aquarium software](https://github.com/aquariumbio/aquarium).

Everyone else should visit the installation page on [Aquarium.bio](https://www.aquarium.bio/?category=Getting%20Started&content=Installation).

---

## Getting Started

1. Install [Docker](https://www.docker.com/get-started)

   The instructions use the [GitHub CLI](https://cli.github.com) instead of [git](https://git-scm.com).

   [Perl](https://www.perl.org) is needed by some of the support scripts

2. Get Aquarium with the command

   ```bash
   gh repo clone aquariumbio/aquarium
   ```

3. Initialize the environment

   ```bash
   cd aquarium
   bash ./bin/setup.sh
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

3. **Stop** the Aquarium services, by typing `ctrl-c` followed by

   ```bash
   docker-compose down
   ```

   Alternatively, you can run this command in a separate terminal within the `aquarium` directory.

   > Caution: using the `-v` option will delete the database.
   > If you actually want to delete the database, but keep a copy, you should do a dump first.
   > See [Switching Databases](#switching-databases)

## Working with an Aquarium Container

To run commands within the running Aquarium container, precede each command with

```bash
docker-compose exec backend
```

For instance, you can run the Rails console with the command

```bash
docker-compose exec backend rails c
````

And, you can also run an interactive shell within the Aquarium container with the command

```bash
docker-compose exec backend /bin/sh
```

which allows you to work within the container.

For commands that don't require that Aquarium is running, using a command starting with

```bash
docker-compose run --rm backend
```

will create a temporary container.
This can be useful for running single commands such as

```bash
docker-compose run --rm backend rspec
```

which runs RSpec on the tests in the `backend/spec` directory.

More details on the docker-compose commands can be found [here](https://docs.docker.com/compose/reference/overview/).

## Docker environment settings

The `bin/setup.sh` script that we ran when [getting started](#getting-started) creates a set of files that sets the environment variables used when running Aquarium with `docker-compose`.
These files are stored in a directory `.env_files` that is organized, roughly, by Rails environment and service

```bash
.env_files
|-- development
|   |-- backend
|   |-- db
|   `-- timezone
`-- production
    |-- backend
    |-- db
    `-- timezone
```

Each file sets environment variables for the [parameters of a service](#parameters).

The environment variables for the database are named differently for the Rails `backend` and MySQL `db` services, and so are defined in both files.

| `backend`     | `db`             |
| ------------- | ---------------- |
| `DB_NAME`     | `MYSQL_DATABASE` |
| `DB_USER`     | `MYSQL_USER`     |
| `DB_PASSWORD` | `MYSQL_PASSWORD` |

If you change either of these definitions, be sure to change the other.
There is a helper script `bin/dbrename.sh` to change the database name.

> Note: the `db` parameter `MYSQL_ROOT_PASSWORD` does not have a corresponding variable in `backend`.

## Managing databases

The development configuration uses the MySQL Docker image, which is capable of automatically importing database dumps the first time it is started.

Specifically, all SQL dumps in the `docker/mysql_int` directory will be loaded if the database has not been initialized.
This will include the first time you run `docker-compose up` after either cloning the repository or [deleting the database volume](#deleting-the-database-volume).
The initial configuration has two dump files `default.sql` and `test.sql` containing the databases `aquarium_development` and `aquarium_test`.

### Switching databases

If you want to switch to a database that has a different name than one of the databases with a dump in `docker/mysql_init`, you can [add the new dump](#adding-a-database-dump) and then change the database name with the `bin/dbrename.sh` script.
For example, to change the database name to `drosophila_husbandtry`, use the command

```bash
./bin/dbrename.sh development drosophila_husbandry
```

Alternatively, if the database names conflict, you can switch the database, but doing so will destroy any changes you have made to the current database.
If you want to save these changes, you will have to create a database dump.
The steps for switching databases in this case are:

1. [Create a dump](#creating-a-database-dump) of the current database if you want to be able to restore it later.
2. [Delete the database volume](#deleting-the-database-volume).
3. [Add the replacement dump](#adding-a-database-dump).
4. [Migrate the database](#migrate-the-database) if the replacement database is not up-to-date with the current schema.

Restore the database by following these steps for the new dump you made in the first step.

### Creating a database dump

To make database dump, run the following

```bash
docker-compose up -d db
bash bin/dbdump.sh development
docker-compose down
```

This will create a SQL dump for the database name in the `.env_files/development/backend` configuration file.

### Deleting the database volume

The Aquarium database files are stored in a named volume managed by Docker.
You can see what volumes exist by running

```bash
docker volume ls
```

The volume for the database files will be named `aquarium_db_data` (provided you cloned into the directory `aquarium`), and can be removed with the command

```bash
docker volume rm aquarium_db_data
```

> Note the `-v` option of the `docker-compose down` command will remove *all* of the volumes defined in the compose files and is not recommended.

### Adding a database dump

Then copy the dump of the database that you want to use to the default location:

```bash
cp replacement_dump.sql docker/mysql_init/
```

Note: It may be necessary to run migrations on a database dump from a prior version of Aquarium.
See the migration instructions below.

## Migrating the Database

```bash
docker-compose up -d
docker-compose exec backend env RAILS_ENV=development rake db:migrate
docker-compose down
```

## Running more than one Aquaria

It is possible to run more than one Aquarium instance, but there can be complications that you need to work around.

### Complications

- public ports conflicts –  the default values for the public ports will be the same for each instance configured with `bin/setup.sh`.
  When running two versions of v3, the solution is to change the environment variables in the `.env` files.
  See below for [running v2 and v3](#running-v2-and-v3) together.
- service name conflicts – when starting a service Docker-Compose uses the parent directory and the service name to name the running container.
  If you have two clones named `aquarium` and run both at the same time, you will have name conflicts.
  The simplest solution is to name the clone directories differently.
- docker image name conflicts – images are managed system wide, so if you have two clones and are working with two v3 versions simultaneously the image built by each will have the same name as the other.
  So, building the image in one directory will replace the image in the other.
  Ben's advice is that even though there is a way around this, you should reconsider the choices that led you to this scenario.

### Running v2 and v3

There are scenarios where you might need to run an instance of v2 and v3.

1. Run the following commands to get a new clone with v2:

   ```bash
   gh repo clone aquariumbio/aquarium legacy-aquarium
   cd legacy-aquarium
   bash ./setup.sh
   ```

2. Until v3 is complete, you will likely want to run either `master` or `staging`.
   If using `staging`, checkout that branch `git checkout staging`.
   The highest numbered `v2.x` will also be the most recent v2 release.

3. Edit the `legacy-aquarium/.env` file and set `APP_PUBLIC_PORT`, `S3_PUBLIC_PORT` and `EXTERNAL_DB_PORT` so they do not conflict with the values of the following variables in the `aquarium/.env` file:
`FRONTEND_PUBLIC_PORT`,
`BACKEND_PUBLIC_PORT`,
`DB_PUBLIC_PORT`.

## Testing Aquarium

### Running Tests

```bash
docker-compose run --rm backend rspec
```

Some of the tests do intentionally raise exceptions, so do not be concerned if these failures seem to be missed.

Test coverage is captured by simplecov in the file `coverage/index.html`.

### Adding Tests

Add additional RSpec tests in the `spec` directory.
New tests can use FactoryBot factories for several of the models that are located in the `spec/factories` directory.

## Editing Aquarium

### Documenting changes

Use the CHANGE_LOG file to document changes that Aquarium users may need to know about.

### Formatting Aquarium code

The Aquarium repository is setup to use [RuboCop](https://rubocop.readthedocs.io).

When you make changes to Aquarium code, run the command

```bash
docker-compose run --rm backend rubocop -x
```

to fix layout issues.
Then run the command

```bash
docker-compose run --rm backend rubocop
```

to see if you have introduced any other issues.
This will check for several potential issues that occur in Rails apps.

You should fix any issues, but be certain to test them.
RuboCop can do other auto-corrections, but don't use that feature unless your tests ensure that the behavior is not changed.

Because RuboCop periodically changes, it can be necessary to make changes to the `.rubocop.yml` file in the repository directory.
When the Ruby version is changed the target version in this file should also be changed.

### Fixing Style TODOs

The file `.rubocop_todo.yml` in the `aquarium` repository configures RuboCop so that it will ignore the listed issues when it processes the Ruby code in Aquarium.
This makes it possible for developers to focus on issues that they introduce when changing code.
However, it also identifies issues that we should try to eliminate.

The process of doing this is to pick one issue, fix it, test the fix, and then update the todo file.
When fixing issues make sure that there is a test that will exercise the fix, and be extra careful when applying auto-correct.
_Note_: Some fixes may not be possible without affecting the Krill library for protocols, which could break protocols that are in use.

This command will regenerate the `.rubocop_todo.yml` file

```bash
docker-compose run -rm backend rubocop --auto-gen-config
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

### Modifying this Document

This document is `docs/development/index.md` in the `aquarium` repository.
Keep it up-to-date if you change something that affects Aquarium development.

## Updating Dependencies

1. Start the container

   ```bash
   docker-compose up -d
   ```

2. Open a shell in the Aquarium container

   ```bash
   docker-compose exec backend /bin/sh
   ```

3. Upgrade gems

   ```bash
   bundle update
   ```

4. Commit the new `Gemfile.lock`

5. Update interface files for Sorbet type checking

   ```bash
   bundle exec rake rails_rbi:all
   srb rbi update
   ```

6. Make sure that the system type checks

   ```bash
   srb tc
   ```

7. Commit updated rbi files

8. Update Javascript dependencies

   ```bash
   yarn upgrade
   ```

9. Commit the new `yarn.lock`

10. Exit container shell

    ```bash
    exit
    ```

11. Stop the container

    ```bash
    docker-compose down
    ```

## Making an Aquarium Release

1.  Ensure that your clone is up to date

    ```bash
    git pull
    ```

2.  Build image to make sure that dependencies are up-to-date

    ```bash
    docker-compose build backend
    ```

3.  Make sure Rails tests pass

    ```bash
    docker-compose up -d
    docker-compose exec backend rspec
    docker-compose down
    ```

    If there are any failures, fix them and start over.

    > Note: you can do all all of the following steps with Aquarium still running by using `docker-compose exec` instead of `docker-compose run --rm`. Just postpone running `down` until after the last step.

4.  Run type checks

    ```bash
    docker-compose run -rm backend srb tc
    ```

    If there are any failures, fix them and start over.

5.  Fix any layout problems

    ```bash
    docker-compose run --rm backend rubocop -x
    ```

6.  Run `rubocop`

    ```bash
    docker-compose run --rm backend rubocop
    ```

    Fix any issues and start over.

7.  Update RuboCop TODO file

    ```bash
    docker-compose run -rm backend rubocop --auto-gen-config
    ```

8.  (make sure JS tests pass)

9.  (Make sure JS linting passes)

10. Update the version number in `package.json` and `config/initializers/version.rb` to the new version number.

11. Update API documentation by running

    ```bash
    docker-compose run --rm backend yard
    ```

12. Update `CHANGE_LOG`

    ```bash
    git log v$OLDVERSION..
    ```

13. Ensure all changes have been committed and pushed.

    ```bash
    git status && git log --branches --not --remotes
    ```

    Commit and push any changes found.

14. Create a tag for the new version:

    ```bash
    git tag -a v$NEWVERSION -m "Aquarium version $NEWVERSION"
    git push --tags
    ```

15. [Create a release on github](https://help.github.com/articles/creating-releases/).
    Visit the [Aquarium releases page](https://github.com/klavinslab/aquarium/releases).

    - Click "Tags".
    - Click "add release notes" for the new tag, use the change log as the release notes.
    - Click "publish release".

16. (Update zenodo entry)

17. Push image to Docker Hub

    ```bash
    bash ./aquarium.sh build
    docker push aquariumbio/aquarium:v$NEWVERSION
    ```

## Aquarium Configuration

### Docker image

Files:

```bash
aquarium
|-- Dockerfile                    # defines the image for Aquarium
`-- entrypoint.sh                 # entrypoint for Docker image
```

The Dockerfile defines the images:

- backend-development -- image for running Aquarium in development mode
- aquarium-builder -- temporary image for production builds
- aquarium -- image for running Aquarium in production model

This image is used for both Aquarium and Krill services.

The entrypoint script determines how the image starts up.

### Parameters

Files:

```bash
aquarium
|-- .env                          # docker-compose environment file (see setup.sh)
|-- .env_files                    # environment variable settings (see setup.sh)
|-- docker-compose.yml            # base compose file
`-- setup.sh
```

Aquarium is parameterized to use environment variables to configure it to use with different services.
These are set in the `docker-compose.yml` file using values from the `.env` file.
The script `setup.sh` updates the values in the .env file, creating missing values as needed.
(This script also ensures that a database dump.sql file exists.)

The full set of environment variables is identified below.
Values need to be given unless the variable has a default.

**Database**:
The database is configured to use MySQL by default with the hostname configured for [local deployment](http://klavinslab.org/aquarium-local/).

| Variable    | Description                         | Default      |
| ----------- | ----------------------------------- | ------------ |
| DB_NAME     | the name of the database            | `production` |
| DB_USER     | the database user                   | `aquarium`   |
| DB_PASSWORD | the password of the user            | –            |
| DB_ADAPTER  | the database adapter name           | `mysql2`     |
| DB_HOST     | the network address of the database | `db`         |
| DB_PORT     | the network port of the database    | `3306`       |

**Email**:
To use the AWS SES set the `EMAIL_SERVICE` to `AWS` along with

| Variable              | Description                        | Default |
| --------------------- | ---------------------------------- | ------- |
| AWS_REGION            | the region for the AWS server      | –       |
| AWS_ACCESS_KEY_ID     | the access key id for your account | –       |
| AWS_SECRET_ACCESS_KEY | the access key for your account    | –       |

**Krill**:
Set the environment variable `KRILL_HOST`

| Variable   | Description                         | Default |
| ---------- | ----------------------------------- | ------- |
| KRILL_HOST | the hostname for the krill server   | `krill` |
| KRILL_PORT | the port served by the krill server | 3500    |

**Timezone**:
Set the variable `TZ` to the desired timezone for your instance.
This should match the timezone for your database.

### Instance configuration

Files:

```bash
aquarium
|-- biofab-eula.yml               # example of end user license agreement for a lab
`-- instance.yml                  # (optional) specifies instance
```

Some configuration can be done using a couple of YAML files.

The first is the file `instance.yml` with keys for the values you want to set.
For instance, to change the name of the instance to `Wonder Lab` use the file

```yaml
default: &default
  instance_name: Wonder Lab

production:
  <<: *default

development:
  <<: *default
```

And, then map the Aquarium path `/aquarium/config/instance.yml` to this file.
For instance, in the docker-compose.yml file, add the following line to the `volumes` for
the aquarium service:

```yaml
- ./instance.yml:/aquarium/config/instance.yml
```

The following values can be set using this file or environment variables:

| Config key           | Environment Variable | Default             |
| -------------------- | -------------------- | ------------------- |
| lab_name             | LAB_NAME             | `Your Lab`          |
| lab_email_address    | LAB_EMAIL_ADDRESS    | –                   |
| logo_path            | LOGO_PATH            | `aquarium-logo.png` |
| technician_dashboard | TECH_DASHBOARD       | `false`             |

In addition to the instance details, the user agreement for the lab can be set by creating a YAML file containing the agreement.
The YAML must include the keys `title` with the title of the agreement, `updated` with the date last updated, and `clauses`, which is a list of pairs of `title` and `text` pairs.
The default can be found in the file `config/user_agreement.yml`:

```yaml
title: End User Agreement
updated: 21 January 2020
clauses:
  - title: No User Agreement
    text: This instance of Aquarium has no user agreement. If you manage this instance, you may want to add one.
  - title: Agreement file format
    text: |
      A user agreement is given as a YAML file with values for 'title' and 'updated' and a list 'clauses'.
      The first two values are strings, and the value for updated is the date.
      Each clause has a 'title' and 'text' both of which are strings.
      The title of each clause should be preceded by a hyphen ('-').
  - title: Find out more
    title: More detail on configuration can be found at the site aquarium.bio.

```

To use a different file, say the `biofab-eula.yml` file, add the following line to the `volumes` for
the aquarium service:

```yaml
- ./biofab-eula.yml:/aquarium/config/user_agreement.yml
```

### Execution environment

Files:

```bash
aquarium
.
|-- bin
|   |-- dbdump.sh                 # script to create a dump of the active database
|   |-- dbrename.sh               # script to change db name in environment variables
|   |-- develop-compose.sh        # script to run Aquarium in development mode (for compatibility)
|   `-- setup.sh                  # script to create default environment variable settings
|-- docker
|   `-- mysql_init                # directory for database dumps to initialize database
|-- docker-compose.override.yml   # development compose file
`-- docker-compose.yml            # base compose file
```

The variants of `docker-compose.yml` files determine how the services used by Aquarium are configured.

The script `develop-compose.sh` is a convenience script for running the `docker-compose` command for Aquarium in development mode.
