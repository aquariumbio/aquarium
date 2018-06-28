---
title: Show Block Documentation
layout: default
---
# Show Block Documentation

This is the documentation for using `ShowBlocks` to display instructions on the technician view, for use in writing effective Aquarium protocols.

This page will give examples and instructions on how to get started using `ShowBlocks`, but it is not a comprehensive reference for all `ShowBlock` related methods. 
See the [API documentation]({{ site.baseurl }}{% link /api/index.html %}) for more details on the functions that Krill provides.

If you haven't already, visit the [protocol developer documentation]({{ site.baseurl }}{% link _docs/protocol_developer/index.md %}) for information about getting started.

---
# IN PROGRESS


## Table of Contents



## Hello Technician

`ShowBlocks` are the object that facilitates interaction between protocol code and an Aquarium technician who is running the protocol. `ShowBlocks` are created and displayed in the technician view with the `show` method. `show` takes a single argument: a code block. This code block contains the contents that are intended to be shown to the technician. This might take the form of instructions with how to proceed with a protocol, or of user input fields to collect sample measurements for storing in the lab database. Each call to `show` constitutes a new slide in the technician view that will be shown while running the protocol. Lets create a simple protocol with a `ShowBlock` that says "Hello World"

```ruby
class Protocol
  def main
    show do 
        note "Hello World" 
    end
  end
end
```

When run from the technician view this protocol has a single step:

![Hello World]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/1_hello_world-1.png %})

Making a protocol with multiple steps is as simple as calling `show` multiple times

```ruby
class Protocol
  def main
    show do
        note "Hello"
    end
    show do
        note "World"
    end
  end
end
```

The above code produces a protocol with two steps

![Hello World]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/2_hello_world-2.png %})
![Hello World]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/3_hello_world-3.png %})

You may have noticed that naked Strings cannot be placed directly into `ShowBlocks`. Any object intended for display to the technician must be in the block as an argument of a `ShowBlock` instance method.
`note` is such an instance method. It takes a String and displays it directly on the technician view slide as a single line.
`title` is another which does the same thing, except the String will be displayed as a header. 

Many Show blocks are composed mostly of a single `title` call, and one or more `note` calls that liberally use string insertion. For instance, here is a show block that asks the technician to grab some amount of 1.5mL tubes

```ruby
    show do 
      title "Grab 1.5 mL tubes"   
      note "Grab #{operations.length} 1.5 mL tubes"
    end
```

When run in a protocol with 5 operations, the technician would see the following instruction

![Serious Protocol]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/4_serious_example.png %})

## ShowBlock Methods

For a comprehensive list of methods that are available for use in `ShowBlocks`, see the [API documentation on ShowBlocks]({{ site.baseurl }}{% link /api/Krill/ShowBlock.html %})

The most commonly used `ShowBlock` methods are the following:

- `title` - accepts a String, which is used as the header for this slide
- `note` - accepts a String and appends it as a new line on the slide
- `check` - accepts a String and appends it as a new line on the slide with a checkbox next to it
- `warning`- accepts a String and appends it as a new line on the slide, bold and highlighted in yellow 
- `image` - accepts a filepath to a valid image, and displays it on the slide
- `table` - accepts either a 2d array or a `Table` object, and displays it on the slide. See the [Table Documentation]({{ site.baseurl }}{% link _docs/protocol_developer/table.md %}) for more details on how to generate and display `Tables` to the technician. 
- `get` - ask the technician for input which will be usable throughout the rest of the protocol. See the [Getting Technician Input Section](#getting_technician_input) for more details.

## Dynamic ShowBlocks

As already mentioned, we can achieve somewhat dynamic `ShowBlocks` by inserting ruby expressions into the Strings displayed by `note` using the ruby String insertion `#{}`.
It is also possible to use complex ruby code within the code blocks of the `show` method to programatically decide how `ShowBlock` methods will be executed. For instance, 

```ruby
    show do 
      title "Grab 1.5 mL tubes"   
      note "Grab #{operations.length} 1.5 mL tubes"
    end
```

## Getting Technician Input