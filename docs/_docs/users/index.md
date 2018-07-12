---
title: Managing Users
layout: docs
permalink: /users/
---

# User Management

## Table of Contents

<!-- TOC -->

- [User Management](#user-management)
    - [Table of Contents](#table-of-contents)
    - [Create an Aquarium Account](#create-an-aquarium-account)
    - [Adding users in Aquarium](#adding-users-in-aquarium)
    - [Creating Groups](#creating-groups)
    - [Changing Passwords](#changing-passwords)
    - [Retiring Users](#retiring-users)

<!-- /TOC -->

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

![choosing users]({{ site.baseurl }}{% link _docs/users/images/settings-menu.png %})

Then enter the user information and click **New User**

![creating user]({{ site.baseurl }}{% link _docs/users/images/new-user.png %})

This will bring you to the user information page where user contact information should be entered:

![new user page]({{ site.baseurl }}{% link _docs/users/images/new-user-page.png %})

The exclamation points on this page indicate that the user hasn't provided contact information, and has not agreed to usage terms.
The user will need to login separately to agree to the usage terms.

A user must have administrative priviledge to access the protocol development tools.
For this, choose **Groups** from the settings menu, choose the group, and then click add:

![add user to group]({{ site.baseurl }}{% link _docs/users/images/add-to-group.png %})

Also, a user must have an associated budget to run any workflows.

## Creating Groups

## Changing Passwords

## Retiring Users
