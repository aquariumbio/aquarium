# Aquarium Protocol Development

These guidelines are for building protocols to run in Aquarium.
For documentation about working on Aquarium itself see the [Aquarium Developer Guidelines](aquarium_developer).

## Table of Contents
* [Introduction](#introduction)
* [Getting Started](#getting-started)
* [Running the Dockerized development server](#running-the-dockerized-development-server)
* [Developer Tools](#developer-tools)
  * [Working in Aquarium](#working-in-aquarium)
  * [Working with External Tools](#working-with-external-tools)
* [Protocol Tutorial](protocol-tutorial.md)

## Introduction

A *protocol* in Aquarium is the code that generates the instructions that the technician will follow.
Each protocol is specified as part of an operation type, which also includes a declaration of the input/output of the protocol, pre-conditions for the protocol, a cost-model for the protocol, documentation and scheduling details for running the protocol in the lab.

[EXPAND]

## Getting Started

To develop Aquarium protocols you will need an Aquarium server to work with, and know some basic Ruby.

We recommend you use the dockerized Aquarium or other personal server for development.
Certainly, testing should not be done on a production server, since protocol errors can affect system performance, and protocols that create database entries can polute your database.
For a personal server, follow the [Installation](installation.md) instructions on your machine.
The user you use should have `admin` access to the system to be able to use the Developer tools.

Basic protocol authoring does not require extensive Ruby knowledge, and an online tutorial should be sufficient to get started.
Also, check out the [Ruby Page](https://www.ruby-lang.org/en/) for documentation.
However, object-oriented Ruby can be useful for building a better library of protocols, for which the [POODR](http://www.poodr.com) book is a good resource.

## Running the Dockerized development server

To run an Aquarium instance on your machine, you will need to have Docker running on your computer, and you will need to clone the Aquarium repository.
Once you have done both of these, `cd` into the `aquarium` directory and create the Docker images that will be used to run Aquarium by running

```bash
docker-compose build
```

It is a good idea to start the database before you start Aquarium for the first time.
Do this by running

```bash
docker-compose up db
```

This will pull the contents of `docker/mysql_init/dump.sql` into the database, and write the database files to the `docker/db` directory.

You can then start Aquarium with

```bash
docker-compose up
```

which is the command you can use for all future runs.
Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser and you should find the Aquarium login page.
The default database has a user login `neptune` with password `aquarium`.

To stop the Aquarium services, you can either run

```bash
docker-compose down
```

in a different window, or type `ctrl-c`.

## Developer Tools

[intro to working with protocols/op types]

### Working in Aquarium

[Describe the developer tab]

### Working with External Tools

Because Aquarium protocols are written in a Ruby DSL, you can edit protocols outside of Aquarium and copy them in.
This allows you to use an editor that you are comfortable with, and also use tools such as [Rubocop](https://rubocop.readthedocs.io/en/latest/) to check for issues in your protocol code.
Many developers simply cut and paste the whole protocol or library code between the Aquarium and external editors.

The [Parrotfish](https://klavinslab.org/parrotfish) tools currently being developed make this a little easier, allowing protocols to be pushed and pulled from an Aquarium instance using the command line.



