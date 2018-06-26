---
title: Aquarium Developer Guidelines
layout: docs
permalink: /aquarium_development/
---

# Aquarium Development Guide

These guidelines are intended for those working directly on Aquarium, though some details are shared with protocol development.

---

<!-- TOC -->

- [Aquarium Development Guide](#aquarium-development-guide)
    - [Getting Started](#getting-started)
    - [Running Aquarium](#running-aquarium)
    - [Testing Aquarium](#testing-aquarium)
    - [Editing Aquarium](#editing-aquarium)
        - [Documenting changes](#documenting-changes)
        - [Formatting Aquarium code](#formatting-aquarium-code)
        - [Documenting Aquarium Ruby Code](#documenting-aquarium-ruby-code)
    - [Modifying the Site](#modifying-the-site)
    - [Making an Aquarium Release](#making-an-aquarium-release)

<!-- /TOC -->

## Getting Started

Follow the Aquarium [installation](Installation.md) instructions to get a local copy of the Aquarium git repository.

## Running Aquarium

## Testing Aquarium

## Editing Aquarium

### Documenting changes

### Formatting Aquarium code

### Documenting Aquarium Ruby Code

Aquarium Ruby methods and classes should be documented with [Yardoc](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md) regardless of whether they are public.

For instance, a function would be documented as

```ruby
# Display the instructions for centerfuging the given tubes.
#
# @param tubes [Array] the array of items representing tubes
def centerfuge_instructions(tubes)
  ...
end
```

unless a hash argument is used, in which case the comment would look like

```ruby
# Copy the data associations from the source item to the target item.
#
# @param args [Hash] the arguments indicating source and target items
# @option args [String] :source  the source item
# @option args [String] :target  the target item
def copy_associations(args)
  ...
end
```

Here are some ([borrowed](http://blog.joda.org/2012/11/javadoc-coding-standards.html)) style guidelines for documentation:

- Write your comments to be read from the source file.
  So, add formatting that is helpful to the programmer reading your code.
- The first sentence of the should be short, clear and to the point.
  Use the third person, e.g., "Returns the item ID for..."
- If documenting a class, use "this" to refer to an instance of the class.
- Aim for one (short) sentence per line.
  Each should end with a period.
- Use `@param` for all parameters, `@return` for return values, and `@raise` for exceptions raised.
  List these in that order.
- Put a single blank line after the first sentence, and then one after each paragraph.
  (If this doesn't give you a line before the first `@param` add one.)
- Write `@param` and `@raise` as a phrase starting with a lowercase letter and almost always the word "the", but with no period.
- Write `@raise` as a conditional phrase beginning with "if".
  Again, don't end the phrase with a period.

See also these yard [examples](https://gist.github.com/chetan/1827484)

The return value of a function should be documented using the `@return` tag, and any exception raised by a function should be documented with the `@raise` tag.
But, there are many more [tags](http://www.rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List) available, and you should feel free to use them.

Running the command

```bash
yard
```

will generate the documentation and write it to the directory `docs/api`.
This location is determined by the file `.yardopts` in the project repository.
This file also limits the API to code used in Krill the protocol development language.

## Modifying the Site

The Aquarium project pages settings display the files in the `docs` directory of the `master` branch as the project site [http://klavinslab.org/aquarium](http://klavinslab.org/aquarium).

The site is built from the [kramdown](https://kramdown.gettalong.org) flavor of Markdown using GitHub flavored [Jekyll](https://jekyllrb.com).
It riffs off of the [Cayman theme](https://github.com/pages-themes/cayman), set through the project pages settings for the Aquarium project.
The files in `docs/_layouts`, `docs/_includes`, `docs/_sass`, and `docs/assets/css` define changes that override the theme defaults.

The content of the site is located in the files in `docs/_docs` with each subdirectory having a `index.md` file that is loaded when the directory name is used (e.g., `klavinslab.org/aquarium/docs/manager` maps to the file `docs/_docs/manager/index.md`).
These Markdown files have a `permalink` that determines this mapping.
Each directory also has an images directory that the files in the directory can reference.


## Making an Aquarium Release

_this is a draft list_

1.  (make sure Rails tests pass)
2.  Run rubocop, fix anything broken. Once done run `rubocop --auto-gen-config`.
3.  Update API by running `yard`
4.  (make sure JS tests pass)
5.  Make sure JS linting passes
6.  Update change log
