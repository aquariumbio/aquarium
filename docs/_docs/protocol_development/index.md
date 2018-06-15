---
layout: default
permalink: /docs/protocol_development/
---
# Aquarium Protocol Development

These guidelines are for building protocols to run in Aquarium.
For documentation about working on Aquarium itself see the [Aquarium Developer Guidelines](aquarium_developer).

## Table of Contents

<!-- TOC -->

- [Aquarium Protocol Development](#aquarium-protocol-development)
    - [Table of Contents](#table-of-contents)
    - [Introduction](#introduction)
    - [Running Aquarium for Protocol Development](#running-aquarium-for-protocol-development)
    - [Writing Protocols](#writing-protocols)
    - [Developer Tools](#developer-tools)
        - [Working in Aquarium](#working-in-aquarium)
        - [Working with External Tools](#working-with-external-tools)

<!-- /TOC -->

## Introduction

A _protocol_ in Aquarium is the code that generates the instructions that the technician will follow.

To develop Aquarium protocols you will need to

- setup an Aquarium server to work with,
- learn how to write protocols,
- understand the development tools.

## Running Aquarium for Protocol Development

We recommend you use the dockerized Aquarium for protocol development, because there are fewer steps involved.
To do this you will have to [install Docker](https://docs.docker.com/install/) on your computer.
To run Aquarium on Windows your system either needs to meet the requirements of [Docker for Windows](https://www.docker.com/docker-windows), or you have to use the older [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/).

Note that our setup scripts are written for a Unix&trade; environment. They will work on OSX, Linux, or inside the Docker Toolbox VM on Windows.

We understand that it might seem simpler to set up a single instance of Aquarium and use that as the production server and protocol development.
However, protocol testing _should not_ be done on a production server, because protocol errors can affect system performance, and protocols that create database entries can pollute your database.

_These instructions are for setting up a local Aquarium and are not meant for production instances._

1. Clone the Aquarium repository

   ```bash
   git clone git@github.com:klavinslab/aquarium.git
   ```
    Or, if using Docker Toolbox for Windows
    ```bash
   git clone git@github.com:klavinslab/aquarium.git --config core.autocrlf=input
   ```

2. Run the `development-setup.sh` script to setup the development environment

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

3. To build the docker images, run the command

   ```bash
   docker-compose build
   ```

   For protocol development, this should only be necessary to do before running Aquarium for the first time after cloning or pulling the repository.
Though, if you have trouble, try running this step again.

4. To start aquarium, run the command

   ```bash
   docker-build up
   ```

   which starts the services for Aquarium.
   The first run will take longer, primarily because it is setting up the database.

   Once all of the services for Aquarium have started, visit `localhost:3000` with the Chrome browser and you will find the Aquarium login page. If running aquarium inside the docker toolbox VM, the address will be instead be `192.168.99.100:3000`.
   The default database has a user login `neptune` with password `aquarium`.

1. To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running

   ```bash
   docker-compose down
   ```   
   
Some configuration notes:

1. When running Aquarium, you may notice a prominent name **Your Lab** in the upper lefthand corner. If this bugs you, you can change it to something you prefer. Do this by editing replacing the string at the end of the first line in `config/initializers/aquarium.rb`, which is currently

   ```ruby
   Bioturk::Application.config.instance_name = 'Your Lab'
   ```

   You might change it to `'LOCAL'` or even `'George'`.
   The choice is yours.

2. The Docker configuration stores the database files in `docker/db`.

   The database is initialized with the contents of docker/mysql_init/dump.sql`, but changes you make will persist between runs.

   You can use a different database database dump by renaming it to this file, removing the contents of the `docker/db` directory and restarting Aquarium.

3. Uploaded files will be placed in the directory `docker/s3`.

## Writing Protocols

Protocols are written in the _Krill protocol language_, a domain specific language built using Ruby.
The [Protocol tutorial](protocol_tutorial) gives an overview of using Krill to define protocols, and assumes a basic understanding of Ruby.

If you are not familiar with Ruby, a good place to start is the [Ruby page](https://www.ruby-lang.org/en/) that has links to introductory tutorials as well as general documentation.
There are also courses on Ruby that are available online, which may be the place to start if you don't already know how to program.

For the more advanced coding useful for library development, you should learn about object-oriented design.
The [POODR](http://www.poodr.com) book is a good resource.

## Developer Tools

Aquarium has a Developer tab that supports creating and editing new protocols, though it is also possible to work on protocols outside of Aquarium.

Developers actually create an _operation type_, which includes the protocol as code along with several other components that are described below.

### Working in Aquarium

The Developer tab is the interface for working with operation types in Aquarium.
Clicking on the Developer tab in Aquarium brings you to a view similar to this one.
On the left is the list of operation types and libraries organized by category, and the right pane is the operation type definition view.
When you open the tab, the definition for the first operation type in the first category is displayed; in this case, the `Make PCR Fragment` operation type from the `Cloning` category.

![developer tab](images/index_developer_tab.png)

Under each category, the libraries and operation types defined in that category are listed.
Clicking on the name of the library or operation type will open the definition in the view on the right.

![category list](images/index_developer_category_list.png)

Clicking on `New` creates a new operation type (`New Lib` creates a new library), and opens the definition view.

This allows you to set the operation type and category type names.

[details]

![definition tab](images/index_developer_definition_tab.png)

Clicking on the **Protocol** tab opens the protocol editor.
For a new operation type a default protocol is added to the editor when you first open it.
[Keyboard shortcuts](https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts) are available.

![protocol tab](images/index_developer_protocol_tab.png)

Be sure to click **Save** at the bottom of the page before switching from the Developer tab.

Clicking on the **Pre** tab shows the precondition for the operation type in a new editor.
A default precondition that always returns `true` is created for new operation types.

![precondition tab](images/index_developer_pre_tab.png)

The **Cost** tab shows the cost model for the operation type, which is function on an `Operation`.
This function returns a map object with costs for `labor` and `materials` keys.
The default function added for new operation types returns zero for both.

![cost tab](images/index_developer_cost_tab.png)

The **Docs** tab shows another editor, but this time for Markdown documentation for the operation type.

![docs tab](images/index_developer_doc_tab.png)

The **Timing** tab indicates when the operation type should be run in the lab.

![timing tab](images/index_developer_timing_tab.png)

The **Test** tab provides a way to run a quick test with the protocol.
To run a test, specify the `Batch Size`, the number of operations to batch, click **Generate Operations** and then **Test**.
This will generate random inputs for the operations and run the protocol.

![test tab](images/index_developer_test_tab.png)

Note that running tests this way doesn't allow testing assertions.
Also, don't use the test tab on a production server.

### Working with External Tools

Because Aquarium protocols are written in a Ruby DSL, you can edit protocols outside of Aquarium and copy them in.
This allows you to use an editor that you are comfortable with, and also use tools such as [Rubocop](https://rubocop.readthedocs.io/en/latest/) to check for issues in your protocol code.
Many developers simply cut and paste the whole protocol or library code between the Aquarium and external editors.

The [Parrotfish](http://klavinslab.org/parrotfish) tools currently being developed make this a little easier, allowing protocols to be pushed and pulled from an Aquarium instance using the command line.
