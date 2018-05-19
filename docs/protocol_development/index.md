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

[this needs a configured docker container and instructions...]



## Developer Tools

[intro to working with protocols/op types]

### Working in Aquarium

[Describe the developer tab]

### Working with External Tools

Because Aquarium protocols are written in a Ruby DSL, you can edit protocols outside of Aquarium and copy them in.
This allows you to use an editor that you are comfortable with, and also use tools such as [Rubocop](https://rubocop.readthedocs.io/en/latest/) to check for issues in your protocol code.
Many developers simply cut and paste the whole protocol or library code between the Aquarium and external editors.

The [Parrotfish](https://klavinslab.org/parrotfish) tools currently being developed make this a little easier, allowing protocols to be pushed and pulled from an Aquarium instance using the command line.



