---
title: Installation
layout: docs
permalink: /installation/
---

# Installing and Running Aquarium

We recommend that labs doing protocol development run at least two instances:
the first, a nursery server that is shared within the lab for the purposes of trying out protocols under development, while the second is the production server that controls the lab.
We use this arrangement in the Klavins lab to run the UW BIOFAB so that protocols can be evaluated without affecting the actual lab inventory.
In addition, each protocol developer should run a local instance, which can be done easily with Docker.

## Table of Contents

<!-- TOC -->

- [Installing and Running Aquarium](#installing-and-running-aquarium)
    - [Table of Contents](#table-of-contents)
    - [Choosing your Approach](#choosing-your-approach)
    - [Manual Installation Instructions](#manual-installation-instructions)
    - [Docker Installation Instructions](#docker-installation-instructions)

<!-- /TOC -->

## Choosing your Approach

**Manual Installation**:
If your goal is to run Aquarium in production mode with many users, you should install and run Aquarium manually.
This requires first installing Ruby, Rails, MySQL, and, depending on the deployment, a web server.
The UW BIOFAB, for example, runs Aquarium on an Amazon Web Services EC2 instance using the web server [nginx](http://nginx.org) and the MySQL database running on a separate RDBMS instance.

We discuss some of the considerations for running Aquarium below, but your deployment may require fine-tuning beyond what we describe.

[Jump to manual installation instructions](#manual-installation-instructions).

**Docker Installation**:
If your goal is instead to run Aquarium on your laptop to evaluate it, develop new code, or serve a small lab, we have provided a Docker configuration scripts to run Aquarium.

[Jump to docker installation instructions](#docker-installation-instructions).

We strongly encourage protocol developers to use the Docker version in production mode, because it eliminates several of the manual configuration details.
Once a protocol runs well on a local instance, you can port it to your production instance using import on the developer tab.

We understand that it might seem simpler to set up a single instance of Aquarium and use it as the production server and for protocol development.
However, protocol testing _should not_ be done on a production server, because protocol errors can affect system performance, and protocols that create database entries can pollute your production database.

## Manual Installation Instructions

To manually install Aquarium in a production environment:

1.  Ensure you have a Unix-like environment on your machine and have installed

    - [git](https://git-scm.com)
    - [Ruby](https://www.ruby-lang.org/en/) version 2.3.7
    - [npm](https://www.npmjs.com/get-npm)
      <br><br>

2.  Also, make sure that you have a [MySQL](https://www.mysql.com) server installed.

    When installing Aquarium on AWS or another cloud service, you should use RDBMS or the database services available there.

3.  Get the Aquarium source code by either downloading the
    [latest release](https://github.com/klavinslab/aquarium/releases/latest),
    or cloning the repository.

    The latest release is available as either a zip or tar.gz file.
    Download the file that you are able to un-compress.
    For instance, on a Unix machine, download the tar.gz file, and use the command

    ```bash
    tar xzf aquarium-v2.201.tar.gz
    ```

    Replacing the file name with the name for the latest release.

    Alternatively, clone the repository and checkout the latest tagged commit

    ```bash
    git clone https://github.com/klavinslab/aquarium.git
    cd aquarium
    latest=`git describe --tags`
    git checkout $latest
    ```

    Note: this version may be more recent than the latest release.

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
    And, in this case, you don't need to worry about the remainder of the `database.yml` file.

    Otherwise, the default settings for the _development_ and _test_ modes should be sufficient, unless you want to use a full database in _development_ mode.
    Regardless, the _test_ mode for running Aquarium system tests should use the `sqlite3` server.

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

    Also, start the Krill server

    ```bash
    rails runner "Krill::Server.new.run(3500)"
    ```

## Docker Installation Instructions

_These instructions are for setting up a local Aquarium and are not meant for production instances._

To run Aquarium with Docker:

1.  Install [Docker](https://docs.docker.com/install/) on your computer.

    Note that our setup scripts are written for a Unix&trade; environment.
    They will work on OSX, Linux, or inside the Docker Toolbox VM on Windows.
    To run Aquarium on Windows your system either needs to meet the requirements of
    [Docker for Windows](https://www.docker.com/docker-windows),
    or you have to use the older
    [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/).

2.  Either get the latest release
    [latest release](https://github.com/klavinslab/aquarium/releases/latest)
    and uncompress the file, or clone the Aquarium repository

    ```bash
    git clone git@github.com:klavinslab/aquarium.git
    ```

    If using Docker Toolbox for Windows

    ```bash
    git clone git@github.com:klavinslab/aquarium.git --config core.autocrlf=input
    ```

3.  To build the docker images, run the command

    ```bash
    docker-compose build
    ```

    For protocol development, this should only be necessary before running Aquarium for the first time after cloning or pulling the repository.
    Though, run this step again if you have trouble and changes may have been made.

4.  To start aquarium on non-Windows platforms, run the command

    ```bash
    docker-compose up
    ```

    which starts the services for Aquarium.
    The first run initializes the database, and will take longer than subsequent runs.

    On Windows, instead use the command

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.windows.yml
    ```

    Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser to find the Aquarium login page.
    If running Aquarium inside the docker toolbox VM, the address will be instead be `192.168.99.100:3000`.
    When started using the default database, aquarium has a single user with login `neptune` and password `aquarium`.

5.  To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running

    ```bash
    docker-compose down
    ```

Some notes:

1.  The base Aquarium Docker image uses configuration files located in `docker/aquarium` instead of the corresponding files in the `config` directory.
    So, if you want to tweak the configuration of your Aquarium Docker installation, change these files.

2.  When running Aquarium, you may notice a prominent name **Your Lab** in the upper left-hand corner.
    If this bugs you, you can change it to something you prefer by replacing the string at the end of the first line in `docker/aquarium/aquarium.rb`, which is currently

    ```ruby
    Bioturk::Application.config.instance_name = 'Your Lab'
    ```

    You might change it to `'LOCAL'` or even `'George'`.
    The choice is yours.

3.  The Docker configuration stores the database files in `docker/db`.

    The database is initialized with the contents of `docker/mysql_init/dump.sql`, but changes you make will persist between runs.

    You can use a different database database dump by renaming it to this file, removing the contents of the `docker/db` directory and restarting Aquarium.

4.  The Docker configuration uses the directory `docker/s3` as the storage location of file uploads and is managed using [Minio](https://minio.io).
    This is probably not the best choice for full production instances.

5.  The Docker configuration uses a email testing container, meaning that email notifications will not work.
