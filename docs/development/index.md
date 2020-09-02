# Aquarium Development Guide

These guidelines are intended for those working directly on the [Aquarium software](https://github.com/aquariumbio/aquarium).

Everyone else should visit the installation page on [Aquarium.bio](https://www.aquarium.bio/?category=Getting%20Started&content=Installation).

---

## Getting Started

1. Install [Docker](https://www.docker.com/get-started)

2. Get Aquarium using [git](https://git-scm.com) with the command

   ```bash
   git clone https://github.com/klavinslab/aquarium.git
   ```

3. Initialize the environment

   ```bash
   cd aquarium
   bash ./setup.sh
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

More details on the docker-compose commands can be found [here](https://docs.docker.com/compose/reference/overview/).

## Switching databases

The development configuration uses the MySQL Docker image, which is capable of automatically importing a database dump the first time it is started.
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
See the migration instructions below.

## Restoring the default database dump

If you want to restart from an empty database, you can run

```bash
cp docker/mysql_init/default.sql docker/mysql_init/dump.sql
```

Before restarting Aquarium, remove the MySQL files with

```bash
rm -rf docker/db/*
```

## Migrating the Database

```bash
docker-compose up -d
docker-compose exec app env RAILS_ENV=production rake db:migrate
docker-compose down -v
```

## Testing Aquarium

### Running Tests

```bash
docker-compose run --rm app rspec
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
docker-compose run --rm app rubocop -x
```

to fix layout issues.
Then run the command

```bash
docker-compose run --rm app rubocop
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

    > Note: you can do all all of the following steps with Aquarium still running by using `docker-compose exec` instead of `docker-compose run --rm`. Just postpone running `down` until after the last step.

4.  Run type checks

    ```bash
    docker-compose run -rm app srb tc
    ```

    If there are any failures, fix them and start over.

5.  Fix any layout problems

    ```bash
    docker-compose run --rm app rubocop -x
    ```

6.  Run `rubocop`

    ```bash
    docker-compose run --rm app rubocop
    ```

    Fix any issues and start over.

7.  Update RuboCop TODO file

    ```bash
    docker-compose run -rm app rubocop --auto-gen-config
    ```

8.  (make sure JS tests pass)

9.  (Make sure JS linting passes)

10. Update the version number in `package.json` and `config/initializers/version.rb` to the new version number.

11. Update API documentation by running

    ```bash
    docker-compose run --rm app yard
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

- aquarium-development -- image for running Aquarium in development mode
- aquarium-builder -- temporary image for production builds
- aquarium -- image for running Aquarium in production model

This image is used for both Aquarium and Krill services.

The entrypoint script determines how the image starts up.

### Parameters

Files:

```bash
aquarium
|-- .env                          # docker-compose environment file (see setup.sh)
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

**S3**:
Aquarium is configured to use either AWS S3 or minio, and is set to use minio by default with the hostname configured for [local deployment](http://klavinslab.org/aquarium-local/).

To use minio set the following variables

| Variable             | Description                             | Default          |
| -------------------- | --------------------------------------- | ---------------- |
| S3_PROTOCOL          | network protocol for S3 service         | `http`           |
| S3_HOST              | network address of the S3 service       | `localhost:9000` |
| S3_REGION            | name of S3 region                       | `us-west-1`      |
| S3_BUCKET_NAME       | name of S3 bucket                       | `development`    |
| S3_ACCESS_KEY_ID     | the access key id for the minio service | –                |
| S3_SECRET_ACCESS_KEY | the access key for the minio service    | –                |

For the local deployment, the minio service is named `s3`, but it is necessary to redirect `localhost:9000` in order to use the minio docker image.

To use AWS S3 set the variable `S3_SERVICE` to `AWS` along with the following variables

| Variable             | Description                        | Default |
| -------------------- | ---------------------------------- | ------- |
| S3_REGION            | name of S3 region                  | –       |
| S3_BUCKET_NAME       | name of S3 bucket                  | –       |
| S3_ACCESS_KEY_ID     | the access key id for your account | –       |
| S3_SECRET_ACCESS_KEY | the access key for your account    | –       |

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

| Config key        | Environment Variable | Default                               |
| ----------------- | -------------------- | ------------------------------------- |
| lab_name          | LAB_NAME             | `Your Lab`                            |
| lab_email_address | LAB_EMAIL_ADDRESS    | –                                     |
| logo_path         | LOGO_PATH            | `aquarium-logo.png`                   |
| image_uri         | IMAGE_URI            | _S3_PROTOCOL_`://`_S3_HOST_`/images/` |

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
|-- aquarium.sh                   # script to run Aquarium in production mode
|-- develop-compose.sh            # script to run Aquarium in development mode (for compatibility)
|-- docker
|   |-- db                        # directory to store database files
|   |-- mysql_init                # database dump to initialize database
|   |-- s3                        # directory for minio files
|   |-- nginx.development.conf    # nginx configuration for development server
|   `-- nginx.production.conf     # nginx configuration for production server
|-- docker-compose.override.yml   # development compose file
|-- docker-compose.production.yml # production compose file
|-- docker-compose.windows.yml    # windows compose file
|-- docker-compose.selenium.yml   # adds selenium service
`-- docker-compose.yml            # base compose file
```

The variants of `docker-compose.yml` files determine how the services used by Aquarium are configured.
Within the aquarium repository these are set to run Aquarium using MySQL for the database, minio for S3, and nginx as the reverse proxy.
The compose files mount relevant files in the `docker` sub-directory, which is where the database and S3 files are stored.
The S3 data files depend on the `S3_SECRET_ACCESS_KEY` and so have to be removed when this value is changed, so be careful if data needs to be kept.

The scripts `aquarium.sh` and `develop-compose.sh` are convenience scripts for running the `docker-compose` commands for Aquarium in production and development modes.
