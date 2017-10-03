Installation
============

Prerequisites
--

* [Ruby on rails](http://rubyonrails.org/)
* [git](https://github.com/)
* A unix like environment, e.g. Mac OSX or Linux
* A MySQL server (optional for a full, production level installation)
    
Get the code
--

To use the latest stable release, go to the [release page](https://github.com/klavinslab/aquarium/releases) and get either the zip file or tar.gz file and unpackage it on your local computer.

If you want to use the bleeding edge code, you can clone the code to your local computer using git, as in 

	git clone https://github.com/klavinslab/aquarium

Configure Aquarium
--

Go to aquarium/config/initializers and do

	cp aquarium_template.notrb aquarium.rb
	
Then edit aquarium.rb. In particular, you should change the workflow github information.

Go to aquarium/config and do

	cp database_template.yml database.yml
	
Then edit database.yml to suit your local configuration. You probably don't need to change anything if you are running in "Development"" mode. Otherwise, you need to set up a MySQL server and associate a user name and password. 

You can install all the gems

	bundle install

If rails complains about "An error occurred while installing mysql2 (0.3.13)...", you should install mysql on your local computer or server.

Initialize the database with

  RAILS_ENV=development rake db:schema:load rake db:schema:load

You can also use production or rehearse in place of development. Anything that is specified in database.yml is okay.

If you are working with a production or rehearse server, then you need to precompile the assets with something like

  RAILS_ENV=production bundle exec rake assets:precompile

Start Aquarium
--

Run

	RAILS_ENV=development rails s
	
to start aquarium. Then go do http://localhost:3000/ and see if it works!

This procedure should start a "Development" mode version with a local sqlite database in the db directory. This could be enough for some labs. However, the Klavins lab runs two versions of Aquarium using MySQL and [Phusion Passenger](https://www.phusionpassenger.com/index2). The first version is the "rehearsal" version, and the second version is the "production" version. This setup allows us to (a) periodically copy the databases from production to rehearsal servers via the ""Admin->Mirror Production" menu and (b) practice protocols without messing up our actual inventory. Details on installing Passenger can be found online.

You will also need to start the Krill server, which is expected to be running on port 3500 in development mode:

	rails runner "Krill::Server.new.run(3500)"

Create an Account
--

Go to Admin->New User and make an account. This first account should be given administrative privilages so you can use it to make more accounts.

If above does not work, you can try create a user with admin previleges in Rails console by doing the following:

	RAILS_ENV=production rails c
    load 'script/init.rb'
    make_user "Your Name", "your login", "your password", admin: true

Congratulations, you've installed Aquarium. Now go to Help and read about Plankton, Krill, and Oyster.




	
