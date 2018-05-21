# Protocol Tutorial

This is an introduction to writing protocols for Aquarium in the Krill domain specific langauge.
We try to introduce the most common (and recommended) patterns in Krill, but this is not a comprehensive reference.
See the [API documentation](../api/index.html) for more details on the functions that Krill provides.

If you haven't already, visit the [protocol development documentation](index.md) for information about getting started.

---

## Table of Contents

* [The Basic Protocol](#the-basic-protocol)
* [Creating Technician Instructions](#creating-technician-instructions)
* [Try an Example](#try-an-example)
* [Working with Samples](#working-with-samples)
  * [Provisioning Items](#provisioning-samples)
  * [Creating Items and Samples](#creating-items-and-samples)
* [Managing Operations](#managing-operations)
* [Protocol Patterns](#protocol-patterns)
  * [Protocols that Create New Items](#protocols-that-create-new-items)
  * [Protocols that Measure Items](#protocols-that-measure-items)
  * [Protocols that Modify Items](#protocols-that-modify-items)
* [Building libraries](#building-libraries)


---

## The Basic Protocol

A protocol is a Ruby class named `Protocol` with a `main` method that includes code that defines what happens in the protocol.
A simple example is

```ruby
class Protocol
  def main
    show { title "Getting Started" }
  end
end
```

where the body of `main` displays a single page titled "Getting Started".
When the protocol is started, Aquarium extends the Protocol class with the Krill methods described below.

## Running a Protocol

You'll probably want to follow along with the examples as you go through this tutorial.
To do this, decide on a category name for your operation types.
An obvious name is `tutorial`, but if you are working on a shared Aquarium you'll need to be more creative.



[ADD instructions]

## Creating Technician Instructions

The primary goal of a protocol is to display the instructions that technicians follow.
Each screen is created by a `show`-block that indicates what is to be displayed.
For instance, the following show block provides instructions to clean up after using a scale in a protocol:

```ruby
show do
  title "Clean up"

  note "Discard all weighing paper, weighing boats and plastic spatulas into the non-biohazard waste"
  note "Wash spatulas with tap water. Dry and return to beaker next to scale"
  note "Use a damp kimwipe to wipe scale till there is no solid powder left anywhere on it"
end
```

The words `title` and `note` are functions that determine the appearance of the text on the constructed page.
This example renders as

![Using note displays text](images/clean-up-note.png)

We could also use `bullet` here instead of `note` for the list of tasks.
However, we want to have the techinician confirm each step, and so use `check` instead:

```ruby
show do
  title "Clean up"

  check "Discard all weighing paper, weighing boats and plastic spatulas into the non-biohazard waste"
  check "Wash spatulas with tap water. Dry and return to beaker next to scale"
  check "Use a damp kimwipe to wipe scale till there is no solid powder left anywhere on it"
end
```

which gives the output

![Using check displays a checkbox](images/clean-up-check.png)

where the technicians must tap each checkbox before they can move to the next page.

There are several other style functions that can be used in a `show`-block that are covered later.


## Working with Samples

* [basic definitions with realistic examples]
* [sample, containers (object type) and items (and collections) through examples]

* [Want to provide basic examples that illustrate important concepts around items that are commonly used]

### Provisioning Items

* [take and release]

### Creating Items and Samples

* [produce and release]

## Managing Operations

Protocols also manage how a batch of operations using the protocol will be performed.
A protocol is able to refer to a batch of operation using the symbol `operations`.

A simple protocol will apply the same tasks to each operation.
For instance, this protocol [DOES SOMETHING]

```ruby
class Protocol
  def main
    operations.each do |operation|
      operation_task(operation)
    end
  end

  def operation_task(operation)
    show do
        title "MAKE A REALISH EXAMPLE"
    end
  end
end
```

The `operation_task` helper function defines the tasks for an operation. Organizing the code this way separates the part of the protocol that operates over all operations from the part that operates over an individual operation.

This _single operation_ idiom is useful, but there may be other scenarios where a _grouped operation_ idiom is better.

```ruby
class Protocol
  def main
    groups1, groups2 = make_groups(operations)

    operation_group_1_task(group1)
    operation_group_2_task(group2)
  end

  def make_groups(operations)
  end

  def operation_group_1_task(operation_group)
    show do
        title "MAKE A REALISH EXAMPLE"
    end
  end

  def operation_group_1_task(operation_group)
    show do
        title "MAKE A REALISH EXAMPLE"
    end
  end
end
```

## Protocol Patterns

Most protocol tasks fall into one of three categories:

* Tasks that take input items and use them to create output items,
* Tasks that modify their input items, and
* Tasks that measure their input items, producing files.

### Protocols that Create New Items

The most common form of protocol takes input items and generates output items.
Such protocols will follow these general steps:

1.  Tell the technician to get the input items.
2.  Create IDs for the output items.
3.  Give the technican instructions for how to make the output items.
4.  Tell the technician to put everything away.

We saw earlier that we can write protocols that do these steps at a detailed level, but Aquarium provides functions that will do them over the inputs and outputs of the batched operations.
So, we can write the protocol to manage these tasks relative to the batched operations, which is simpler.

A protocol is able to refer to a batch of operation using the symbol `operations`, and calls `operations.retrieve`, `operations.make` and `operations.store` to perform the steps above.

As an example, the following protocol illustrates this pattern for [DOING SOMETHING].

```ruby
def main
  # 1. Locate required items and display instructions to get them
  operations.retrieve
  # 2. Create inventory items for the outputs
  operations.make

  operations.each do |operation|
    # 3. Instructions how to perform steps to produce results
    operation_task(operation)
  end

ensure
    # 4. Put everything away
    operations.store
end
```

The use of `ensure` in this example makes certain that `operations.store` is called even if an exception is raised by the call to `operation_task`.

[Accessing Inputs and Outputs]

```ruby
def operation_task(operation)
  show do
    title "MAKE A REALISH EXAMPLE"
  end
end
```

### Protocols that Measure Items

Another common protocol uses an instrument to measure a sample.
Instruments frequently save the measurements to a file, and so the protocol consists of instructions for first taking the measurement, and then uploading the file(s).

[data associations]

### Protocols that Modify Items

[handling time: timers vs scheduling]

## Building Libraries

[saving work with shared functions - include, extend, direct call]

[simplifying with kinds of ducks: using classes]

[things that go awry: show blocks in libraries]

