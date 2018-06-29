---
title: ShowBlock Documentation
layout: default
---
# ShowBlock Documentation

This is the documentation for using `ShowBlocks` to display instructions on the technician view, for use in writing effective Aquarium protocols.

This page will give examples and instructions on how to get started using `ShowBlocks`, but it is not a comprehensive reference for all `ShowBlock` related methods. 
See the [API documentation]({{ site.baseurl }}{% link /api/index.html %}) for more details on the functions that Krill provides.

If you haven't already, visit the [protocol developer documentation]({{ site.baseurl }}{% link _docs/protocol_developer/index.md %}) for information about getting started.

---
# IN PROGRESS


## Table of Contents

<!-- TOC -->

- [ShowBlock Documentation](#table-documentation)
    - [Table of Contents](#table-of-contents)

<!-- /TOC -->



## "Hello Technician"

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
It is also possible to use complex ruby code within the code blocks of the `show` method to programatically decide how `ShowBlock` methods will be executed. 

For instance, we could modify our earlier show block to give different instructions depending on the amount of `Operations` the protocol is run with

```ruby
    show do 
      title "Grab 1.5 mL tubes"   
      if operations.length > 50
        note "Go to the storeroom and bring back #{operations.length} 1.5 mL tubes to bench"
      end
      note "Grab #{operations.length} 1.5 mL tubes from bench"
    end
```

Running this on the technician view, we would see an additional line of instruction being offered when the protocol is run with 51 or more `Operations`

We can achieve powerful emergent behaviour by using ruby code inside `ShowBlocks`. Another example, using loops

```ruby
    show do 
      title "Grab 1.5 mL tubes"   
      operations.each do |op|
        check "Grab a tube for operation: #{op.id}"
      end
    end
```

Here is the output on the Technician view for the latter example with 5 `Operations`

![Serious Protocol]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/5_dynamic_example.png %})

## Getting Technician Input

There are two `ShowBlock` methods that are used to retrieve input from the technician: `get` and `select`. They work in the same way, except that `get` allows the technician to enter a String response, and `select` has the technician select an item from a dropdown menu.

`get` provides a textbox for the technician to enter a String. Its first parameter is the type of input, as "number", or "text", and it also requires the `var:` option to hold a valid keyname, as the key that will be later used to access the inputted data. Here is the code for a simple show block that prompts the technician for a response

```ruby
show do
    title "Please Respond"
    note "What is your first name?"
    get "text", var: :tech_name 
end
```

This would display the following slide to the technician

![User Input Example]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/6_input_block-1.png %})


We can customize the textbox further with the `label:` and `default:` options

```ruby
show do
    title "Please Respond"
    note "What is your first name?"
    get "text", var: :tech_name, label: "Enter name", default: "Joe Schmo" 
end
```

Now our textbox is a bit more informative

![User Input Example]({{ site.baseurl }}{% link _docs/protocol_developer/images/show_images/7_input_block-2.png %})

Any input data from a ShowBlock is returned by the call to `show` that created the block in a Hashlike object. The name that we entered as the option for var: will be the key of this hash that the relevant data is stored in.

In order to access the name entered by the technician, we would have to capture the return of `show` in a variable, and then access it at the key `:tech_name`

```ruby
data = show do
    title "Please Respond"
    note "What is your first name?"
    get "text", var: :tech_name, label: "Enter name", default: "Joe Schmo" 
end

data[:tech_name] #=> "Joe Schmo"
```

`select` has almost the same interface as get, except instead of giving a type as the first parameter, we must provide an array of selection options. For example, we might want to prompt the tech to report the status of a bacterial plate – whether it is normal, a lawn, or contaminated

_Example from `Cloning/Check Plate`_

```ruby
data = show do
    title "Report Plate status"
    
    operations.each do |op|
        plate = op.input("Plate").item
        select ["normal", "contamination", "lawn"], var: "status-#{plate.id}", label: "For plate #{plate}, choose whether there is contamination, a lawn, or whether it's normal."
    end
end
```

Notice that this time we are storing data for each `Operation`, so we must parameterize the `var:` option, otherwise all the selections would be stored under the same key in the data hash.

Here is what the slide would appear like to the technician

TODO[picture of slide, using data hash with parameterized var:]

To use the data stored in the Check Plate example, we have to parameterize our hash access in the same way as we did while storing the data

```ruby
operations.each do |op|
    plate = op.input("Plate").item
    data["status-#{plate.id}"] #=> <selection response for that Plate>
end
```

Another convienent way to collect information relating to each `Operation` in an  `OperationList` is to accept technician responses through a input `Table` on the `OperationsList`. See the [Table Documentation on getting User Input]({{ site.basename }}{% link _docs/protocol_developer/table.md/accepting-technician-input-through-tables}) for more details.