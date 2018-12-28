# Aquadoc

The purpose of aquadoc is to generate a github repository and web page (using github pages) you can use to publish and
share a set of [Aquarium](http://klavinslab.org/aquarium) operation types and their protocols.

## Installation

This gem is under construction, so it is not yet available on RubyGems.
To install it from github do:

```bash
gem install specific_install
gem specific_install https://github.com/klavinslab/aquadoc
```

Alternatively, you can use docker, as in

```bash
git clone https://github.com/klavinslab/aquadoc.git
cd aquadoc
docker build -t aquadoc env
docker run -v /path/to/MyWorkflow:/home/MyWorkflow -it aquadoc bash
cd MyWorkflow
```

where MyWorkflow is a directory containing your workflow as described below.

## Usage: Command Line

First, from the [Aquarium](http://klavinslab.org/aquarium) Developer tab,
export a set of categories and put them in a directory called categories.
Then create a config.json.
Your directory structure should look like the following:

    MyWorkflow
    |
    + config.json
    + categories
      |
      + MyCategory1.json
      + MyCategory2.json
      + ...

The README.md file will be used as the front page of the resulting web page.
The config.json file should look something like

```json
{
  "title": "My Workflow",
  "description": "A workflow for doing x, y and z",
  "copyright": "2018 Me or My Organization",
  "version": "0.0.1",
  "authors": [{ "name": "First Last", "affiliation": "Organization Name" }],
  "maintainer": {
    "name": "First Last",
    "email": "me@my.org"
  },
  "acknowledgements": [
    { "name": "First Last", "affiliation": "Organization Name" }
  ],
  "github": {
    "repo": "name",
    "user": "login",
    "access_token": "40 characters from github"
  }
}
```

Then run

    aquadoc

from within the MyWorkflow directory. This will produce the directory

    MyWorkflow/html

which you can serve up using your favorite web server. Typically, the entire MyWorkflow directory
would be turned into a github repository and github pages would be pointed to the html directory.
You would use github versions, tags, and releases to maintain versions of your code.

## Usage: API

Given a list of categories and a configuration file, you can do

```ruby
require 'aquadoc'

Aquadoc::Git()config, categories).run
```

to generate the github repo. See the [Aquarium](http://klavinslab.org/aquarium) documentation
for more information.
