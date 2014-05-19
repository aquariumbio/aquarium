Installation
============

Prerequisites (for a sqlite install)
--

	* [Ruby on rails](http://rubyonrails.org/)
    * [git](https://github.com/)
    * A unix like environment, e.g. Mac OSX or Linux
    * A MySQL server (for a proper installation)
    
Get the code
--

Clone the code to your local computer using git, as in 

	git clone https://github.com/klavinslab/aquarium


Install Protocols
--
	
Install at least one repository of protocols, such as aqualib, as follows:

	cd aquarium/repos
	git clone https://github.com/klavinslab/aqualib
	
You may also want to start your own repository of protocols. For example, do (from within my_protocols):

	mkdir my_protocols
	cd my_protocols

Then create a new file called hello.pl with the following code in it:

	step
		description: "Hello World"
	end
	
Finally, add your new protocols to the repo

	git init
	git add .
	git commit -m "Initial commit"
	
These protocol libraries will be accessible via the "Protocols -> Under Version Control" menu.

Configure Aquarium
--

Go to aquarium/config/initializers and do

	cp aquarium_template.notrb aquarium.rb
	
Then edit aquarium.rb. You probably won't want to change anything initially.

Go to aquarium/config and do

	cp database_template.yml database.yml
	
Then edit database.yml to suit your local configuration. You probably don't need to change anything if you are running in "Development"" mode. Otherwise, you need to set up a MySQL server and associate a user name and password. 

Start Aquarium
--

Run

	rails s
	
to start aquarium. Then go do http://localhost:3000/ and see if it works!

Create an Account
--

Go to Admin->New User and make an account. This first account should be given administrative privilages so you can use it to make more accounts.

Run Hello World
--

Go to Protocols->Under Version Control and choose myprotocols/hello.pl and run the protocol.

Keep Going
--

Congratulations, you've installed Aquarium. Now go to Help and read about Plankton and Oyster.




	