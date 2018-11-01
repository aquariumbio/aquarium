# Aquadoc

The purpose of aquadoc is to generate a web page you can use to publish and share a set of Aquarium operation types and their protocols.

## Installation

Under construction

## Usage

First, from the Aquarium Developer tab, export a set of categories and create a local directory of the form

    MyWorkflow
    |
    + README.md
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

    ruby aquadoc MyWorkflow

from within the directory containing the MyWorkflow directory. This will produce the directory

    MyWorkflow/html

which you can serve up using your favorite web server. Typically, the entire MyWorkflow directory
would be turned into a github repository and github pages would be pointed to the html directory.
You would use github versions, tags, and releases to maintain versions of your code.
