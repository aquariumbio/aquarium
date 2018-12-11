---
title: Aquarium Developer Guidelines
layout: docs
permalink: /aquarium_development/
---

# Aquarium Development Guide

These guidelines are intended for those working directly on Aquarium, though some details are shared with protocol development.

---

<!-- TOC -->

- [Aquarium Development Guide](#aquarium-development-guide)
    - [Getting Started](#getting-started)
    - [Running Aquarium](#running-aquarium)
    - [Testing Aquarium](#testing-aquarium)
    - [Editing Aquarium](#editing-aquarium)
        - [Documenting changes](#documenting-changes)
        - [Formatting Aquarium code](#formatting-aquarium-code)
        - [Documenting Aquarium Ruby Code](#documenting-aquarium-ruby-code)
    - [Modifying the Site](#modifying-the-site)
    - [Making an Aquarium Release](#making-an-aquarium-release)
    - [Docker configuration](#docker-configuration)
        - [Images](#images)
        - [Database](#database)
        - [Compose files](#compose-files)
        - [Local web server](#local-web-server)

<!-- /TOC -->

## Getting Started

Follow the Aquarium [installation]({{ site.baseurl }}{% link _docs/installation/index.md %}) instructions to get a local copy of the Aquarium git repository.

## Running Aquarium

To run Aquarium in development mode using the Docker configuration (in a Unix-like environment), do the following:

1. Build the docker images with

   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
   ```

2. Start Aquarium with

   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
   ```

> NOTE: If you have previously run Aquarium in production mode you will have to run `rm -rf docker/db/*` before restarting in development mode.

Stop the services by typing `ctrl-c` followed by

```bash
docker-compose down
```

As you work on Aquarium, you will want to run commands that need the Aquarium Ruby environment (e.g., `rails` commands).
To avoid having to do the manual installation steps, you can simply precede each command with

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run -rm app
```

## Testing Aquarium

## Editing Aquarium

### Documenting changes

### Formatting Aquarium code

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

## Modifying the Site

The Aquarium project pages settings display the files in the `docs` directory of the `master` branch as the project site [http://klavinslab.org/aquarium](http://klavinslab.org/aquarium).

The site is built from the [kramdown](https://kramdown.gettalong.org) flavor of Markdown using GitHub flavored [Jekyll](https://jekyllrb.com).
It riffs off of the [Cayman theme](https://github.com/pages-themes/cayman), set through the project pages settings for the Aquarium project.
The files in `docs/_layouts`, `docs/_includes`, `docs/_sass`, and `docs/assets/css` define changes that override the theme defaults.

The content of the site is located in the files in `docs/_docs` with each subdirectory having a `index.md` file that is loaded when the directory name is used (e.g., `klavinslab.org/aquarium/manager` maps to the file `docs/_docs/manager/index.md`).
These Markdown files have a `permalink` that determines this mapping.
Because of the way that general permalinks are defined in `docs/_config.yml`, other markdown documents correspond to a URL with the file name.
For instance, `klavingslab.org/aquarium/protocol_developer/table/` maps to the file `docs/_docs/protocol_developer/table.md`.

To avoid issues creating links using standard Markdown hyperlinks, use the Liquid `link` tag that will do the mapping from the file path.
This tag takes the absolute path relative to the `docs` directory, so use `{% link _docs/installation/index.md %}` to get the link for the file `docs/_docs/installation/index.md`.
However, this link will be relative to the `docs` directory, and to get the complete mapping we have to add the base URL for the site.
So use `{{ site.baseurl }}{% link _docs/installation/index.md %}` to get the correct link on the generated page.
Using the link tag to reference image files in the `images` subdirectory for each topic will avoid discrepancies between a local preview and how the site is displayed on GitHub.

Unfortunately, images linked this way will actually not be rendered in a local preview.
To see the pages rendered properly, install the `github-pages` gem, run `jekyll serve` from the `docs` directory, and visit `localhost:4000` with a browser.
For more detail, see the [instructions](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/) from GitHub.

## Making an Aquarium Release

_this is a draft list_

1.  (make sure Rails tests pass)
2.  Run rubocop, fix anything broken. Once done run `rubocop --auto-gen-config`.
3.  Update API documentation by running `yard`
4.  (make sure JS tests pass)
5.  Make sure JS linting passes
6.  Update version number in [WHATEVER-THAT-FILE-IS]
6.  Update change log
7.  (create a tag for the repository)
8.  (create a release on github)

## Docker configuration

The Aquarium Docker configuration is determined by these files:

```
aquarium
|-- Dockerfile                  # defines the image for Aquarium
|-- docker
|   |-- aquarium                # Aquarium configuration files
|   |-- aquarium-entrypoint.sh  # entrypoint for running Aquarium
|   |-- db                      # directory to store database files
|   |-- krill-entrypoint.sh     # entrypoint for running Krill
|   |-- mysql_init              # database dump to initialize database
|   |-- nginx.development.conf  # nginx configuration for development server
|   |-- nginx.production.conf   # nginx configuration for production server
|   `-- s3                      # directory for minio files
|-- docker-compose.dev.yml      # development compose file
|-- docker-compose.override.yml # production compose file
|-- docker-compose.windows.yml  # windows compose file
`-- docker-compose.yml          # base compose file
```

### Images

The `Dockerfile` configures Aquarium images `basebuilder`, `devbuilder` and `prodbuilder`.
The `devbuilder` and `prodbuilder` images are configured to allow Aquarium to be run as a local instance in the development and production environments, while the `basebuilder` image contains the configuration common to both.

The `basebuilder` configuration copies rails configuration files from the `docker/aquarium` directory into the correct place in the image; and adds the `docker/aquarium-entrypoint.sh` and `docker/krill-entrypoint.sh` scripts for starting the Aquarium services.
The configuration also ensures that the `docker/db` and `docker/s3` directories needed for the database and [minio](https://minio.io) S3 server are created on the host as required by the compose files.
The `devbuilder` and `prodbuilder` configurations build an image with environment specific files.

### Database

The `docker/mysql_init` directory contains the database dump that is used to initialize the database when it is run the first time.
The MySQL service is configured to use the `docker/db` directory to store its files, and removing the contents of this directory (`rm -rf docker/db/*`) will cause the database to initialize the next time the service is started.

The contents of the `docker/db` directory also need to be removed when changing between running in production and development environments.
If you want to save the contents of the database, you will have to perform a database dump from within the `app` container.

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

Running in production is the default configuration, because the most common usage of a local installation is by someone doing protocol development who will want to mirror the production server of the lab.

The `docker-compose build` command needs to be run with the same file arguments as you are intending to run Aquarium.

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
```

This is the same for running a command within the service with `docker-compose run`, such as

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run --rm app /bin/sh
```

which runs a shell within the container running Aquarium in the development environment.



### Local web server

Access to the servers run by compose is handled by nginx.
For the most part, most traffic should go directly to the Aquarium Puma server.

Note that Aquarium allows files to be downloaded by returning a pre-authenticated link to the S3 server.
**BLAH**
