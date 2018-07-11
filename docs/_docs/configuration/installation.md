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
    - [Manual Installation Instructions](#manual-installation-instructions)
    - [Docker Installation Instructions](#docker-installation-instructions)

<!-- /TOC -->

## Choosing your Approach

**Manual Installation**:
If your goal is to run Aquarium in production mode with many users, you should install and run Aquarium directly.
This requires first installing Ruby, Rails, MySQL, and, depending on the deployment, a web server.
The UW BIOFAB, for example, runs Aquarium on an Amazon Web Services EC2 instance using the web server [nginx](http://nginx.org) and the MySQL database running on a separate RDBMS instance.
We discuss some of the considerations for running Aquarium below, but your deployment may require fine-tuning beyond what we describe.

[Jump to manual installation instructions](#manual-installation-instructions).

**Docker Installation**:
If your goal is instead to run Aquarium on your laptops to evaluate it, develop new code, or serve a small lab, we have provided a Docker configuration script that runs Aquarium in the Rails development mode.

[Jump to docker installation instructions](#docker-installation-instructions).

We strongly encourage protocol developers to use the Docker version in development mode, because it eliminates several of the configuration details needed for production.
Once a protocol runs well on a local instance, you can port it to your production instance using Aquarium's import method.

We understand that it might seem simpler to set up a single instance of Aquarium and use it as the production server and for protocol development.
However, protocol testing _should not_ be done on a production server, because protocol errors can affect system performance, and protocols that create database entries can pollute your production database.

## Manual Installation Instructions

To manually install Aquarium in a production environment on a local machine:

1.  Ensure you have a Unix-like environment on your machine and have installed

    - [git](https://git-scm.com)
    - [Ruby](https://www.ruby-lang.org/en/) version 2.3.7
    - [npm](https://www.npmjs.com/get-npm)
      <br><br>

2.  Also, make sure that you have a [MySQL](https://www.mysql.com) server installed.

    (When installing Aquarium on AWS or another cloud service, you should use the database services available there.)

3.  Get the Aquarium source code by either downloading the
    [latest release](https://github.com/klavinslab/aquarium/releases/latest)
    and uncompress, or cloning the repository with the command

    ```bash
    git clone https://github.com/klavinslab/aquarium.git
    ```

    The latest release is available as either a zip or tar.gz file.
    So, if you choose to download the release file, use the appropriate command on your machine to uncompress the file.

4.  Configure Aquarium by first creating the `aquarium/config/initializers/aquarium.rb` file

    ```bash
    cd aquarium/config/initializers
    cp aquarium_template.notrb aquarium.rb
    ```

    and then editing `aquarium.rb` to set the URLs and email address.

5.  Configure the Aquarium database settings.
    First, create the `aquarium/config/database.yml` file with

    ```bash
    cd ..  # aquarium/config
    cp database_template.yml database.yml
    ```

    You should change the _production_ mode configuration to point to your database server.
    And, in this case, you don't need to worry about the remainder of the file.

    Otherwise, the default settings for the _development_ and _test_ modes should be sufficient, unless you want to use a full database in _development_mode.
    Regardless, the \_test_ mode for running Aquarium system tests should use the `sqlite3` server.

6.  Install the Ruby gems required by Aquarium with

    ```bash
    gem install bundler
    bundle install
    ```

    Note: if the MySQL database is not installed or not properly installed/configured, you may get errors during this step.

7.  Install Javascript libraries used by Aquarium with the command

    ```bash
    npm install -g bower
    bower install
    ```

8.  Initialize the database with

    ```bash
    RAILS_ENV=production rake db:schema:load
    ```

    You can also set `RAILS_ENV` to `development` or `rehearse` in place of `production`.
    Any mode that is specified in `database.yml` is okay.

9.  For the production server, precompile the assets:

    ```bash
    RAILS_ENV=production bundle exec rake assets:precompile
    ```

10. To start Aquarium, run

    ```bash
    RAILS_ENV=production rails s
    ```

    and then go do `http://localhost:3000/` to find the login page.

    The Krill server is also needed

    ```bash
    rails runner "Krill::Server.new.run(3500)"
    ```

## Docker Installation Instructions

_These instructions are for setting up a local Aquarium and are not meant for production instances._

To run Aquarium with Docker:

1.  Install [Docker](https://docs.docker.com/install/) on your computer.
    To run Aquarium on Windows your system either needs to meet the requirements of
    [Docker for Windows](https://www.docker.com/docker-windows),
    or you have to use the older
    [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/).

    Note that our setup scripts are written for a Unix&trade; environment.
    They will work on OSX, Linux, or inside the Docker Toolbox VM on Windows.

2.  Either get the latest release
    [latest release](https://github.com/klavinslab/aquarium/releases/latest)
    and uncompress the file, or clone the Aquarium repository

    ```bash
    git clone git@github.com:klavinslab/aquarium.git
    ```

    Or, if using Docker Toolbox for Windows

    ```bash
    git clone git@github.com:klavinslab/aquarium.git --config core.autocrlf=input
    ```

3.  Run the `development-setup.sh` script to setup the development environment

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

4.  To build the docker images, run the command

    ```bash
    docker-compose build
    ```

    For protocol development, this should only be necessary to do before running Aquarium for the first time after cloning or pulling the repository.
    Though, if you have trouble, try running this step again.

5.  To start aquarium, run the command

    ```bash
    docker-compose up
    ```

    which starts the services for Aquarium.
    The first run will take longer, primarily because it is setting up the database.

    Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser and you will find the Aquarium login page. If running aquarium inside the docker toolbox VM, the address will be instead be `192.168.99.100:3000`.
    The default database has a user login `neptune` with password `aquarium`.

6.  To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running

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
