---
title: Configuration
layout: docs
permalink: /docs/configuration/
---

# Aquarium Configuration

## Table of Contents

<!-- TOC -->

- [Aquarium Configuration](#aquarium-configuration)
    - [Table of Contents](#table-of-contents)
    - [Installing Aquarium](#installing-aquarium)
    - [Create an Aquarium Account](#create-an-aquarium-account)
    - [Adding users in Aquarium](#adding-users-in-aquarium)
    - [Building the Inventory](#building-the-inventory)

<!-- /TOC -->

## Installing Aquarium

We recommend that labs doing protocol development run at least two instances:
the first, a "nursery" server that is shared within the lab for the purposes of trying out protocols under development, while the second is the production server that controls the lab.
We use this arrangement in the Klavins lab to run the UW BIOFAB so that protocols can be evaluated without messing up the actual lab inventory.
In addition, each protocol developer should run a local instance, which can be done easily with Docker.

See the [installation instructions](installation) for details.

## Create an Aquarium Account

The dockerized development server already has an adminstrative user with login `neptune` and password `aquarium`.
But if you are running Aquarium from source, you will need to create one.

To create the first administrative user run the commands

```bash
RAILS_ENV=production rails c
load 'script/init.rb'
make_user "Your Name", "your login", "your password", admin: true
```

from the `aquarium` directory.

## Adding users in Aquarium

Once you have an account you can create other users by choosing `Users` in the menu at the top left of the Aquarium page:

![choosing users](images/users/settings-menu.png)

Then enter the user information and click **New User**

![creating user](images/users/new-user.png)

This will bring you to the user information page where user contact information should be entered:

![new user page](images/users/new-user-page.png)

The exclamation points on this page indicate that the user hasn't provided contact information, and has not agreed to usage terms.
The user will need to login separately to agree to the usage terms.

A user must have administrative priviledge to access the protocol development tools.
For this, choose **Groups** from the settings menu, choose the group, and then click add:

![add user to group](images/users/add-to-group.png)

Also, a user must have an associated budget to run any workflows.

## Building the Inventory
