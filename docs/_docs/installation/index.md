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

We strongly encourage protocol developers to use the Docker version in production mode, because it eliminates several of the manual configuration details.
Once a protocol runs well on a local instance, you can port it to your production instance using import on the developer tab.

We understand that it might seem simpler to set up a single instance of Aquarium and use it as the production server and for protocol development.
However, protocol testing _should not_ be done on a production server, because protocol errors can affect system performance, and protocols that create database entries can pollute your production database.

## Table of Contents

<!-- TOC -->

- [Installing and Running Aquarium](#installing-and-running-aquarium)
    - [Table of Contents](#table-of-contents)
    - [Choosing your Approach](#choosing-your-approach)
    - [Getting Aquarium](#getting-aquarium)
    - [Manual Installation Instructions](#manual-installation-instructions)
    - [Docker Installation Instructions](#docker-installation-instructions)
        - [Running Aquarium with Docker](#running-aquarium-with-docker)
        - [Stopping Aquarium in Docker](#stopping-aquarium-in-docker)
        - [Updating Aquarium](#updating-aquarium)
        - [Changing the Database](#changing-the-database)
        - [Notes](#notes)

<!-- /TOC -->

## Choosing your Approach

**Manual Installation**:
If your goal is to run Aquarium in production mode with many users, you should install and run Aquarium manually.
This requires first installing Ruby, Rails, MySQL, and, depending on the deployment, a web server.
The UW BIOFAB, for example, runs Aquarium on an Amazon Web Services EC2 instance using the web server [nginx](http://nginx.org) and the MySQL database running on a separate RDBMS instance.

We discuss some of the considerations for running Aquarium below, but your deployment may require fine-tuning beyond what we describe.

[Jump to manual installation instructions](#manual-installation-instructions).

**Docker Installation**:
If your goal is instead to run Aquarium on your laptop to evaluate it, develop new code, or serve a small lab, we have provided Docker configuration scripts to run Aquarium with nearly all of the supporting services.

[Jump to docker installation instructions](#docker-installation-instructions).

## Getting Aquarium

For both manual and Docker installations you will need to obtain the Aquarium source.
If you use a non-Windows system, do this by using [git](https://git-scm.com) with the command

```bash
git clone https://github.com/klavinslab/aquarium.git
```

On Windows use

```bash
git clone https://github.com/klavinslab/aquarium.git --config core.autocrlf=input
```

By default, this will give you the repository containing the bleeding edge version of Aquarium, and you will want to choose the Aquarium version you will use.
The most definitive way to find the latest release is to visit the [latest Aquarium release](https://github.com/klavinslab/aquarium/releases/latest) page at Github, take note of the tag number (e.g., v2.4.2), and then checkout that version.
For instance, if the tag is `v2.4.2` use the command
```bash
cd aquarium
git checkout v2.4.2
```

(Don't use this command if you are doing development.
See the [git tagging documentation](https://git-scm.com/book/en/v2/Git-Basics-Tagging) for details.)


## Manual Installation Instructions

To manually install Aquarium in a production environment:

1.  Ensure you have a Unix-like environment on your machine and have installed

    - [Ruby](https://www.ruby-lang.org/en/) version 2.3.7
    - [npm](https://www.npmjs.com/get-npm)
      <br>

2.  Also, make sure that you have a [MySQL](https://www.mysql.com) server installed.

    When installing Aquarium on AWS use RDS, or, for another cloud service, use the database services available there.

3.  [Get the aquarium source](#get-aquarium).

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

8.  Initialize the production database with

    ```bash
    RAILS_ENV=production rake db:schema:load
    ```

9.  For the production server, precompile the assets:

    ```bash
    RAILS_ENV=production bundle exec rake assets:precompile
    ```

10. [THIS SHOULD REFER TO PUMA/NGINX CONFIG]
To start Aquarium, run

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

### Running Aquarium with Docker

To run Aquarium in production with Docker on your computer:

1.  Install [Docker](https://docs.docker.com/install/) on your computer.

    Note that our setup scripts are written for a Unix&trade; environment.
    They will work on OSX, Linux, or inside the Docker Toolbox VM on Windows.
    To run Aquarium on Windows your system either needs to meet the requirements of
    [Docker for Windows](https://www.docker.com/docker-windows),
    or you have to use the older
    [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/).

2.  [Get the Aquarium source](#getting-aquarium).

3.  To build the docker images, run the command

    ```bash
    docker-compose build
    ```

    This should only be necessary before running Aquarium for the first time after cloning or pulling the repository.

4.  To start aquarium on non-Windows platforms, run the command

    ```bash
    docker-compose up
    ```

    which starts the services for Aquarium.

    > **Important**:
    > The first run initializes the database, and so will be slower than subsequent runs.
    > This can take longer than you think is reasonable, but let it finish unmolested.

    On Windows, instead use the command

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.windows.yml up
    ```

    Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser to find the Aquarium login page.
    If running Aquarium inside the Docker toolbox VM, the address will be instead be `192.168.99.100:3000`.
    When started using the default database, aquarium has a single user with login `neptune` and password `aquarium`.

### Stopping Aquarium in Docker

To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running

```bash
docker-compose down
```

### Updating Aquarium

When a new version of Aquarium comes available, run

```bash
git pull
docker-compose build
```

to get and build the new version, and then run

```bash
docker-compose run --rm app rails db:migrate RAILS_ENV=production
```

to migrate the database.
Finally, restart Aquarium with `docker-compose` as before.

### Changing the Database

Aquarium database files are stored in `docker/db`, which allows the database to persist between runs.
If this directory is empty, such as the first time Aquarium is run, the database is initialized from the database dump `docker/mysql_init/dump.sql`.

You can use a different database dump by renaming it to this file

```bash
mv my_dump.sql docker/mysql_init/dump.sql
```

and then removing the contents of the `docker/db` directory

```bash
rm -rf docker/db/*
```

and restarting Aquarium with `docker-compose` as before.

> **Important**: If you swap in a large database dump, the database has to be reinitialized.
> And the larger the database, the longer the initialization will take.
> *Let the initialization finish.*

### Notes

1.  The Aquarium Docker image uses configuration files located in `docker/aquarium` instead of the corresponding files in the `config` directory.
    So, if you want to tweak the configuration of your Aquarium Docker installation, change these files.

2.  When running Aquarium, you may notice a prominent **LOCAL** in the upper left-hand corner.
    You can change this to something you prefer by replacing the string at the end of the first line in `docker/aquarium/aquarium.rb`, which is currently

    ```ruby
    Bioturk::Application.config.instance_name = 'LOCAL'
    ```

    For instance, you could replace `'LOCAL'` with `'Georgina'`.

3.  The Docker configuration uses the directory `docker/s3` as the storage location of file uploads and is managed using [Minio](https://minio.io).

4.  The Docker configuration does not provide an email server container, meaning that email notifications will not work.
