---
title: Installation
layout: docs
---

# Installing (and Running) Aquarium

## Table of Contents

<!-- TOC -->

- [Installing (and Running) Aquarium](#installing-and-running-aquarium)
    - [Table of Contents](#table-of-contents)
    - [Choosing your Approach](#choosing-your-approach)
    - [Running from Source](#running-from-source)
    - [Running Aquarium from Docker (Development)](#running-aquarium-from-docker-development)

<!-- /TOC -->

## Choosing your Approach

Aquarium may be installed and run directly from source, or using Docker.
The Docker configuration runs Aquarium in Rails development mode, so if you are installing a production system, you will need to to install from source.

We strongly encourage protocol developers to use Docker, because it eliminates several of the configuration details that users can encounter.

We understand that it might seem simpler to set up a single instance of Aquarium and use that as the production server and protocol development.
However, protocol testing _should not_ be done on a production server, because protocol errors can affect system performance, and protocols that create database entries can pollute your database.

## Running from Source

These are the instructions to install Aquarium from the [source code](https://github.com/klavinslab/aquarium).
If you are doing either protocol development or Aquarium development, we recommend you run Aquarium from Docker.

1.  Ensure you have the following installed on your machine

    - A Unix-like environment, e.g. Mac OSX or Linux
    - [git](https://git-scm.com)
    - [Ruby](https://www.ruby-lang.org/en/) version 2.3.9
    - [npm](https://www.npmjs.com/get-npm)
    - A [MySQL](https://www.mysql.com) server (optional for a full, production level installation)

2. Get the Aquarium source code by either downloading the [latest release](https://github.com/klavinslab/aquarium/releases/latest) and uncompress, or cloning the working master branch with the command

   ```bash
   git clone https://github.com/klavinslab/aquarium.git
   ```

   If you choose to download the latest release, uncompress the file.

3.  Configure Aquarium by first creating the `aquarium/config/initializers/aquarium.rb` file

    ```bash
    cd aquarium/config/initializers
    cp aquarium_template.notrb aquarium.rb
    ```

    and then editing `aquarium.rb` to set the URLs and email address.

4.  Configure the Aquarium database settings. First, create the `aquarium/config/database.yml` file with

    ```bash
    cd ..  # aquarium/config
    cp database_template.yml database.yml
    ```

    This will configure Aquarium to use the default database for _development_ mode.
    You may configure different database servers for different modes.
    If you want to use MySQL, you will need to set up the server, and associate a username and password.
    Though, the `test` mode for testing Aquarium system tests should use the `sqlite3` server.

5)  Install the Ruby gems required by Aquarium with

    ```bash
    gem install bundler
    bundle install
    ```

    Note that if you are using MySQL, and the database is not installed or not properly installed, you may get errors during this step.

6)  Install Javascript libraries used by Aquarium with the command

    ```bash
    npm install -g bower
    bower install
    ```

7)  Initialize the database with

    ```bash
    RAILS_ENV=development rake db:schema:load
    ```

    You can also set `RAILS_ENV` to `production` or `rehearse` in place of `development`.
    Any mode that is specified in `database.yml` is okay.

8)  If you are working with a production or rehearse server, then you need to precompile the assets:

    ```bash
    RAILS_ENV=production bundle exec rake assets:precompile
    ```

To start Aquarium, run

```bash
RAILS_ENV=development rails s
```

and then go do `http://localhost:3000/` to find the login page.

This procedure starts a _development_ mode version using the local SQL database in the db directory.
This could be enough for some labs.

To run protocols within Aquarium, you will also need to start the Krill server with the command

```bash
rails runner "Krill::Server.new.run(3500)"
```

## Running Aquarium from Docker (Development)

To run Aquarium with Docker, you will have to [install Docker](https://docs.docker.com/install/) on your computer.
To run Aquarium on Windows your system either needs to meet the requirements of [Docker for Windows](https://www.docker.com/docker-windows), or you have to use the older [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/).

Note that our setup scripts are written for a Unix&trade; environment. They will work on OSX, Linux, or inside the Docker Toolbox VM on Windows.

_These instructions are for setting up a local Aquarium and are not meant for production instances._

1.  Clone the Aquarium repository

    ```bash
    git clone git@github.com:klavinslab/aquarium.git
    ```

    Or, if using Docker Toolbox for Windows

    ```bash
    git clone git@github.com:klavinslab/aquarium.git --config core.autocrlf=input
    ```

2.  Run the `development-setup.sh` script to setup the development environment

    ```bash
    cd aquarium
    ./development-setup.sh
    ```

    Or, if using Docker Toolbox for Windows

    ```bash
    cd aquarium
    ./development-setup.sh windows
    ```

    This script moves default development configuration files into the correct place. You only need to run it once.

3.  To build the docker images, run the command

    ```bash
    docker-compose build
    ```

    For protocol development, this should only be necessary to do before running Aquarium for the first time after cloning or pulling the repository.
    Though, if you have trouble, try running this step again.

4.  To start aquarium, run the command

    ```bash
    docker-build up
    ```

    which starts the services for Aquarium.
    The first run will take longer, primarily because it is setting up the database.

    Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser and you will find the Aquarium login page. If running aquarium inside the docker toolbox VM, the address will be instead be `192.168.99.100:3000`.
    The default database has a user login `neptune` with password `aquarium`.

5.  To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running

    ```bash
    docker-compose down
    ```

Some configuration notes:

1.  When running Aquarium, you may notice a prominent name **Your Lab** in the upper lefthand corner. If this bugs you, you can change it to something you prefer. Do this by editing replacing the string at the end of the first line in `config/initializers/aquarium.rb`, which is currently

    ```ruby
    Bioturk::Application.config.instance_name = 'Your Lab'
    ```

    You might change it to `'LOCAL'` or even `'George'`.
    The choice is yours.

2.  The Docker configuration stores the database files in `docker/db`.

    The database is initialized with the contents of docker/mysql_init/dump.sql`, but changes you make will persist between runs.

    You can use a different database database dump by renaming it to this file, removing the contents of the `docker/db` directory and restarting Aquarium.

3.  Uploaded files will be placed in the directory `docker/s3`.
