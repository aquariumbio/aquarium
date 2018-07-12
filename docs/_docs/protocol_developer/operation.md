---
title: Operation Documentation
layout: docs
---

# Operation Documentation

This is the documentation for how to successfully use the `Operation` and `Job` paradigms from within Aquarium protocols, with explanation of commonly used `Operation` methods.

This page will give examples and instructions on how to get started using `Operation` methods, but it is not a comprehensive reference for all `Operation` related methods.
See the [API documentation]({{ site.baseurl }}{% link /api/index.html %}) for more details on the functions that Krill provides.

---

## Table of Contents

<!-- TOC -->

- [Operation Documentation](#operation-documentation)
    - [Table of Contents](#table-of-contents)
    - [The Operation Interface](#the-operation-interface)
    - [Iterating Through Operatons](#iterating-through-operatons)
    - [Checking and Changing Operation Status](#checking-and-changing-operation-status)
    - [Inputs and Outputs](#inputs-and-outputs)
    - [Adding Inputs After the Protocol has Started](#adding-inputs-after-the-protocol-has-started)

<!-- /TOC -->

---

## The Operation Interface

Operations are created by the user in the Aquarium planner and then batched together by the lab manager in the Aquarium manager to be sent to a protocol.
From within a protocol, it is easy to get a list of the operations that were sent to your protocol with

```ruby
    operations
```

which returns something like an array of operations.
Actually, it is a Rails [ActiveRecord::Relation](http://api.rubyonrails.org/classes/ActiveRecord/Relation.html) object extended with a number of Aquarium specific methods, discussed here.
Just remember that in addition to what you see here, there are also all the standard array methods (like **`each`**, **`collect`**, **`select`**, **`reject`**, ...) and of course the Rails operations (which you probably won't need).

## Iterating Through Operatons

To iterate through all operations, simply use the standard Ruby array method **`each`**, as in the following.

```ruby
operations.each do |op|
  # Do something with op here
end
```

You can also specify whether to iterate over running or errored operations, and use select, reject, and collect operations.
For example, to collect all running operations whose "Template" input has a concentration greater than 100 nM, do the following.

```ruby
my_ops = operations.running.select do |op|
  op.input_data("Template", :concentration) > 70.0
end
```

You can group operations which can be useful if you want to display a show block for a unique item, sample, or collection.

```ruby
grouped_by_collection = operations.running.group_by do |op|
  op.input("input").collection
end

grouped_by_collection.each do |collection, ops|
    show do
      title "For collection #{collection.id}"

      table ops.start_table
        .input_item("input")
        .end_table
    end
end
```

## Checking and Changing Operation Status

Each operation **`op`** has a status, **`op.status`**.
When a protocol first starts, the status should be "running".
When the protocol completes, Aquarium automatically sets the status to "done".
If for some reason an operation has a problem, your protocol can set the status to "error" as in

```ruby
op.change_status "error"
```

which sets the status and saves the operation.
Subsequent calls to **`operations`** can be filtered by doing **`operations.running`** or **`operations.errored`**.
Note that table operations **`operations.start_table...`** described below default to running operations.

It is common to provide the owner of the operation some information about why you are setting their operation's status to "error".
You can do this with something like

```ruby
  op.change_status "error"
  op.associate :no_growth, "The overnight has no growth."
```

or with the shorthand

```ruby
  op.error :no_growth, "The overnight has no growth."
```

## Inputs and Outputs

Given an operation `op`, you can access its inputs and outputs by name using the `input` and `output` methods, which return a `FieldValue` object.
Each `FieldValue` object has methods that allow you to determine what inventory items, samples, and object_types are associated with the input or output field.
For example, for an operation `op` with an input named `"Primer"`, you can access attributes of the input with the methods

```ruby
op.input("Primer").item
op.input("Primer").sample
op.input("Primer").collection
op.input("Primer").sample_type
op.input("Primer").object_type
```

These methods will return `nil` if the requested object is not found.
Otherwise, you'll get an `ActiveRecord` for an `Item`, `Sample`, `SampleType`, or `ObjectType`, respectively.
The same methods are available for `op.output`.

If an input (or output) is an array, you can get an array of values using

```ruby
op.input_array("Primer")
```

which returns an `Array`-like object with the following methods for access items, samples, etc:

```ruby
op.input_array("Primer").items
op.input_array("Primer").item_id
op.input_array("Primer").samples
op.input_array("Primer").sample_ids
op.input_array("Primer").collections
op.input_array("Primer").collection_ids
op.input_array("Primer").rows       # An array of the rows in which the Primer is found (if the input is a part)
op.input_array("Primer").columns    # An array of the columns in which the Primer is found (if the input is a part)
op.input_array("Primer").rcs        # An array of the [row,column] where the Primer is found  (if the input is a part)
```

The same goes for `op.output_array`.

If an input is a parameter, for example called `"X"`, you can get the value of the parameter for that operation:

```ruby
op.input("X").val
```

The `val` method will return a value of the defined type for the parameter.

Paramters can be numbers, strings, or JSON.
If the parameter is of type JSON then

```ruby
  op.input(“x”).val
```

will return a Ruby object with the same structure as the JSON, and with symbols (not strings) for keys.
Note that if the JSON does not parse, you will get an object of the form.

{ error: “JSON parse error description”, original_value: “whatever you put as the input” }.

## Adding Inputs After the Protocol has Started

Note that for the items associated with an operation to be tracked, they have to be inputs or outputs.
Sometimes, however, you don't know what items a protocol will use ahead of time, or do not need the user to specify them in the planner.
In this case, you can add an input online using op.add_input as in the following code:

```ruby
# This is a default, one-size-fits all protocol that shows how you can
# access the inputs and outputs of the operations associated with a job.
# Add specific instructions for this protocol!

class Protocol

  def main

    primer = Sample.find_by_name("GAI-L2-r")
    container = ObjectType.find_by_name("Primer Aliquot")

    operations.each do |op|
      item = op.add_input "Computed Input", primer, container
    end

    operations.retrieve.make

    operations.store

    return {}

  end

end
```

Here, we know we want the protocol to always use the specified primer (a contrived example), so it is hard coded.
But which item is used is determied by `op.add_input`.
The chosen item is the return value and should be checked for non-`nil`, meaning the method found an item.
