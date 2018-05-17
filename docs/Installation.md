# Installation

These are the instructions to install Aquarium from [the source code](https://github.com/klavinslab/aquarium).

Depending on your circumstances, it may be easier for you to use the [Dockerized Aquarium](https://github.com/klavinslab/aquadocked).

## Prerequisites

* [Ruby on rails](http://rubyonrails.org/)
* [git](https://github.com/)
* A Unix-like environment, e.g. Mac OSX or Linux
* A MySQL server (optional for a full, production level installation)

## Get the code

To use the latest stable release, go to the [release page](https://github.com/klavinslab/aquarium/releases) and get either the zip file or tar.gz file and unpackage it on your local computer.

If you want to use the bleeding edge code, you can clone the code to your local computer using git, as in

```bash
git clone https://github.com/klavinslab/aquarium
```

## Configuration

### Aquarium

Make the `aquarium.rb` configuration file with

```bash
cd aquarium/config/initializers
cp aquarium_template.notrb aquarium.rb
```

and then edit aquarium.rb to correct the URLs and email address.

The port for the Krill server is set in this file, but there is no need to change it.

### Database

Aquarium may be run in *development* mode without installing a database, but depending on your needs you may want to install a database server (such as MySQL).

In both cases, create the `database.yml` file with

```bash
cd ..  # aquarium/config
cp database_template.yml database.yml
```

This is sufficient if you are running Aquarium with the default database, but,otherwise, you need to set up a MySQL server and associate a user name and password.
Note that you can set different database servers for different modes.
(The `test` mode for Aquarium development testing should use the `sqlite3` server.)

### Ruby

Install the Ruby gems required by Aquarium with

```bash
bundle install
```

> If `rails` complains that "An error occurred while installing mysql2 (0.3.13)...", your database configuration says that MySQL should be used but that it is not installed or accessible.

Initialize the database with

```bash
RAILS_ENV=development rake db:schema:load rake db:schema:load
```

You can also set `RAILS_ENV` to `production` or `rehearse` in place of `development`.
Any mode that is specified in `database.yml` is okay.

If you are working with a production or rehearse server, then you need to precompile the assets:

```bash
RAILS_ENV=production bundle exec rake assets:precompile
```

## Start Aquarium

Run

```bash
RAILS_ENV=development rails s
```

to start aquarium. Then go do `http://localhost:3000/` and see if it works!

This procedure starts a *development* mode version using the local SQL database in the db directory.
This could be enough for some labs.

However, the Klavins lab runs two instances of Aquarium using MySQL.
The first version is the "nursery" version, and the second version is the "production" version.
This setup allows us to practice protocols without messing up our actual inventory.

You will also need to start the Krill server:

```bash
rails runner "Krill::Server.new.run(3500)"
```

(The port for the Krill server is set in `config/initializers/aquarium.rb`.)

## Create an Account

Go to `Admin->New User` and make an account.
This first account should be given administrative privileges so you can use it to make more accounts.

You can also create a user with admin previleges in the Rails console by doing the following:

```bash
RAILS_ENV=production rails c
load 'script/init.rb'
make_user "Your Name", "your login", "your password", admin: true
```
