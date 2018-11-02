# Aquadoc

The purpose of aquadoc is to generate a web page you can use to publish and
share a set of Aquarium operation types and their protocols.

## Installation

This gem is under construction, so it is not yet available on RubyGems. To install it from github do:

    gem install specific_install
    gem specific_install https://github.com/klavinslab/aquadoc

## Usage

First, from the Aquarium Developer tab, export a set of categories and put them in a directory called categories.
Then create a README.md, a LICENSE.md, and a config.json. Your directory structure should look like the following:

    MyWorkflow
    |
    + README.md
    + LICENSE.md
    + config.json
    + categories
      |
      + MyCategory1.json
      + MyCategory2.json
      + ...

The README.md file will be used as the front page of the resulting web page.
The config.json file should look something like

    {
      "title": "My Workflow",
      "authors": [ "First Last", "First Last" ]
    }

Then run

    aquadoc

from within the MyWorkflow directory. This will produce the directory

    MyWorkflow/html

which you can serve up using your favorite web server. Typically, the entire MyWorkflow directory
would be turned into a github repository and github pages would be pointed to the html directory.
You would use github versions, tags, and releases to maintain versions of your code.
