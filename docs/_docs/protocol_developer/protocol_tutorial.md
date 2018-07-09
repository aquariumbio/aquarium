---
title: Protocol Development Tutorial
layout: default
permalink: /protocol_tutorial/
---
# Protocol Tutorial

This is an introduction to writing protocols for Aquarium in the Krill domain specific langauge.
We try to introduce the most common (and recommended) patterns in Krill, but this is not a comprehensive reference.
See the [API documentation]({{ site.baseurl }}{% link /api/index.html %}) for more details on the functions that Krill provides.

If you haven't already, visit the [protocol developer documentation]({{ site.baseurl }}{% link _docs/protocol_developer/index.md %}) for information about getting started.

---

## Table of Contents

<!-- TOC -->

- [Protocol Tutorial](#protocol-tutorial)
    - [Table of Contents](#table-of-contents)
    - [An Aquarium Protocol](#an-aquarium-protocol)
    - [The Basic Protocol](#the-basic-protocol)
    - [Running a Protocol](#running-a-protocol)
        - [Creating a Protocol](#creating-a-protocol)
        - [Running a Protocol from the Developer Test Tab](#running-a-protocol-from-the-developer-test-tab)
        - [Running a Deployed Protocol](#running-a-deployed-protocol)
    - [Creating Technician Instructions](#creating-technician-instructions)
    - [Working with Samples](#working-with-samples)
        - [Practicing Queries](#practicing-queries)
        - [Creating Items and Samples](#creating-items-and-samples)
        - [Creating Collections](#creating-collections)
        - [Provisioning Items](#provisioning-items)
    - [Working With Items in Operations](#working-with-items-in-operations)
    - [Managing Operations](#managing-operations)
    - [Protocol Patterns](#protocol-patterns)
        - [Protocols that Create New Items](#protocols-that-create-new-items)
        - [Protocols that Measure Items](#protocols-that-measure-items)
        - [Protocols that Modify Items](#protocols-that-modify-items)
    - [Writing a Protocol](#writing-a-protocol)
    - [Building Libraries](#building-libraries)

<!-- /TOC -->

## An Aquarium Protocol

Each protocol is specified as part of an operation type, which also includes a declaration of the input/output of the protocol, pre-conditions for the protocol, a cost-model for the protocol, documentation and scheduling details for running the protocol in the lab.


## The Basic Protocol

An Aquarium protocol is a Ruby class named `Protocol` with a `main` method that includes code that defines what happens in the protocol.
A simple example is

```ruby
class Protocol
  def main
    show { title 'Getting Started' }
  end
end
```

where the body of `main` displays a single page titled 'Getting Started'.
When the protocol is started, Aquarium extends the Protocol class with the Krill methods described below.

## Running a Protocol

To follow along with the examples as you go through this tutorial, first decide on a category name for your operation types.
For our example, we use `tutorial_neptune` where 'neptune' is the user name.
You'll also want to decide whether you will use the same operation type to try the examples as you go, or make a new one.

And, in case the admonition hasn't yet settled in, **don't** use a production server for testing.

### Creating a Protocol

1.  Starting from the developer tab, click the **New** button in the upper right corner.

    ![the aquarium developer tab]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/1_developer_tab.png %})

    This will create a new operation type in the current category.

    ![a new operation type]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/2_new_operation_type.png %})

2.  Change the operation type name and category and click the **Save** button.

    ![renamed new operation type]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/3_new_operation_type2.png %})

    For this example, we use the name `BasicProtocol` and category `tutorial_neptune`.

3.  Click **Protocol**, replace the body of the main method with the code `show { title 'Getting Started' }` like in our example, and click the **Save** button at the bottom right.

    ![the protocol of the new operation type]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/4_basic_protocol.png %})

### Running a Protocol from the Developer Test Tab

The simplest way to run a protocol is by using testing in the Developer Tab.

1.  Click **Test**

    ![the test view]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/5_basic_protocol_test.png %})

2.  Click the **Generate Operations** button to generate instances of the operation type with random inputs

    ![the test with operations]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/6_basic_protocol_test2.png %})

3.  Click the **Test** button to run the operation(s) with the inputs and show the trace with any output

    ![the test results]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/7_basic_protocol_test3.png %})

In this case, we see the page title 'Getting Started' as output.

### Running a Deployed Protocol

You can run the protocol so that it will show you the screens as the technician will see them, but this is more involved.

1.  In the Developer **Def** view, click the **Deployed** checkbox

    ![click the deploy box]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/8_deployed_basic_protocol.png %})

2.  Click the **Designer** tab at the top of the page, click _Design_, and then choose your category under _Operation Types_

    ![choosing operation for a plan]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/9_plan_design_view.png %})

3.  Click the operation type name `BasicProtocol` to add the operation to the plan

    ![the basic protocol plan]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/10_basic_protocol_plan.png %})

4.  Save the plan, and then click **Launch**. You'll have to select and confirm your budget, and click _Submit_

    ![confirm the budget for the plan]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/11_launch_basic_protocol_plan.png %})

5.  Select the **Manager** tab, and click your category in the list on the left.

    ![Selecting the job]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/12_pending_plan.png %})

6.  Click the pending job for `BasicProtocol`, click the _All_ button and click _Schedule_

    ![Scheduling the job]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/13_selecting_basic_protocol_job.png %})

7.  Click the pending ID under **Jobs**

    ![Selecting job]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/14_scheduling_basic_protocol_job.png %})

8.  Click _Start_

    ![Starting job]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/15_scheduled_basic_protocol_job.png %})

9.  Use the buttons in the Technician view to move through the protocol.

    ![Basic Protocol in the Technician View]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/16_running_basic_protocol.png %})

    Ordinarily, clicking **OK** will move to the next slide, but since there is only one there, the protocol will end.

This process is involved, but under normal operation, there are at least three people involved in these steps: the plan designer, a manager, and a technician.

## Creating Technician Instructions

The primary goal of a protocol is to display the instructions that technicians follow.
Each screen is created by a show-block that indicates what is to be displayed.
For instance, the following show block provides instructions to clean up after using a scale in a protocol:

```ruby
show do
  title 'Clean up'

  note 'Discard all weighing paper, weighing boats and plastic spatulas into the non-biohazard waste'
  note 'Wash spatulas with tap water. Dry and return to beaker next to scale'
  note 'Use a damp kimwipe to wipe scale till there is no solid powder left anywhere on it'
end
```

The words `title` and `note` are functions that determine the appearance of the text on the constructed page.
This example renders as

![Using note displays text]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/17_clean-up-note.png %})

(To see this in action, add the show-block to the main method of the `BasicProtocol`.)

We could also use `bullet` here instead of `note` for the list of tasks.
However, we want to have the techinician confirm each step, and so use `check` instead:

```ruby
show do
  title 'Clean up'

  check 'Discard all weighing paper, weighing boats and plastic spatulas into the non-biohazard waste'
  check 'Wash spatulas with tap water. Dry and return to beaker next to scale'
  check 'Use a damp kimwipe to wipe scale till there is no solid powder left anywhere on it'
end
```

which gives the output

![Using check displays a checkbox]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/18_clean-up-check.png %})

where the technicians must tap each checkbox before they can move to the next page.

There are several other style functions that can be used in a show-block that are covered later.

## Working with Samples

In addition to displaying technician instructions, we also want a protocol to manage the samples that the protocol uses or creates.
For this, an Aquarium protocol manipulates _items_, where each item is a unique instance of a sample in a container.
The item is the physical object that is manipulated.

Concretely, an item is represented by an `Item` object, which consists of a `Sample` object, an `ObjectType` representing the container, as well as a `location`.
An example of an item would be a pMOD8 plasmid streaked onto an agar plate that is sitting on a lab bench.
This plate would be represented as an `Item`, where the `Sample` is `'pMOD8'`, the `ObjectType` is `'E. coli Plate of Plasmid'`, with a location `'Bench'`.
To access this item, we can query the Aquarium inventory.

To find our plate in the inventory, we first need the `Sample` and `ObjectType`.
We get the sample with the query

```ruby
Sample.find_by_name('pMOD8')
```

that returns the `Sample` object with name `pMOD8`.
We do a similar query for the container using

```ruby
ObjectType.find_by_name('E. coli Plate of Plasmid')
```

And, then use these queries to find the item for the plate

```ruby
plate_list = Item.where(
  sample_id: Sample.find_by_name('pMOD8').id,
  object_type_id: ObjectType.find_by_name('E. coli Plate of Plasmid').id
  location: 'Bench'
  )
```

This query returns a list of `Item` objects matching the query, which will be empty if there is no matching item in the inventory.
Alternatively, we can make the query

```ruby
plate_list = Sample.find_by_name('pMOD8').in('E. coli Plate of Plasmid')
```

which returns the list of `Item`s with `Sample` `'pMOD8'` in a container of type `'E. coli Plate of Plasmid'`.
In either case, we expect at least one item that we can extract with the command

```ruby
plate = plate_list.first
```

This call to `plate_list.first` will return `nil` if `plate_list` is empty, and you should always check for this situation before using `plate` for another purpose.

See [Here for more details about Items]({{ site.baseurl }}{% link /api/Item.html %}).

A special type of `Item`, called `Collection` is used to keep track of multiple `Samples`. While an `Item` has one `Sample` object, a `Collection` has an arbitrary amount of `Samples` associated with it. We refer to the slots for `Samples` in a `Collection`  as `Parts`. `Collections` have additional methods which allow protocols to smoothly interact with containers that can hold many things at once, like stripwells. A full stripwell can be represented as a `Collection`, while each individual well in the physical stripwell is represented as a `Part` of that `Collection`.

To perform an _E. coli_ transformation you need a _batch_ of competent cell aliquots. We represent the entire batch as a `Collection`, and each aliquot as one `Part` of that `Collection`.

To retrieve a batch of DH5&alpha;-competent cells from the -80C freezer at UW BIOFAB make this query:

```ruby
batch = Item.where(
  sample_id: Sample.find_by_name('DH5alpha').id,
  location: 'M80C.2.0.21'
  ).first
```

This assigns a single item with object type `'E. coli Comp Cell Batch'` to the variable `batch`.
The location `'M80C.2.0.21'` is a location in the -80C freezer at UW BIOFAB.
(See the [location wizard]({{ site.baseurl }}{% link _docs/protocol_developer/location.md %}) documentation for details on locations.)

The return from the above query will be an ordinary `Item`. To be able to use the object as a `Collection` we call

```ruby
batch = collection_from batch
```

and then can use the `Collection` methods on the object.

See [Here for more details about Collections]({{ site.baseurl }}{% link /api/Collection.html %}).

### Practicing Queries

It can be helpful to use the Rails console for Aquarium to try queries such as those above during protocol development.
From the command line, run

```bash
docker-compose run web rails c
```

in the `aquarium` directory to start the Rails console.
(If you have Aquairum setup to run on your machine without docker you can also just use the command `rails c`)

The allowable queries are standard with Ruby on Rails `ActiveRecord` models.

See [here for details](http://guides.rubyonrails.org/v3.2.21/active_record_querying.html).

### Creating Items and Samples

The function `new_object` and `new_sample` make a new `Item` based on the name of an object type or sample type.
When given to the `produce` function this item is added to the database with new unique ids, and provisioned (e.g., 'taken').

- `new_object name` - This function takes the name of an object type and makes a new item with that object type.
  An object type with that name must exist in the database.
  For example, you might do the following, which would return a new item in the variable `i`.

  ```ruby
  i = produce new_object '1 L Bottle'
  ```

- `new_sample(sample_name, of: sample_type_name, as: object_type_name)` - This function takes a sample name and an object type name and makes a new item with that name.
  For example, you might do the following, which returns a new item in the variable `i` whose object type is 'Plasmid Stock', whose corresponding sample is 'pLAB1' and whose sample type is 'Plasmid'.

  ```ruby
  j = produce new_sample('pLAB1', of: 'Plasmid', as: 'Plasmid Stock')
  ```

  When a protocol is done with a an item, it should release it.
  This is done with the release function.

- `release item_list, opts={} //optional block//` -- release an item.
  This function has many forms.
  Suppose `i` and `j` are items currently ''taken'' by the protocol.

  ```ruby
  release([i,j])
  ```

  - ^ This version of release simply release the items i and j (i.e. it marks them as not taken by the job running the protocol).

```ruby
release([i,j], interactive: true)
```

- ^ This version calls `show` and tells the user to put the items away, or dispose of them, etc.
  Once the user clicks "Next", the items in the list are marked as not taken.

```ruby
release([i,j], interactive: true) {
  warning 'Be careful with these items.'
}
```

- ^ This version also calls `show`, like the previous version, but also adds the `show` code block to the `show` that release does, so that you can add various notes, warnings, images, etc. to the page shown to the user.

### Creating Collections

Collections can be made manually by making a new item with a collection-friendly object type as above, and promoting it to a collection.
You can also use the following static Collection methods for convienence

- `Collection.new_collection 'collection_type_name'` - Creates a new collection of type "collection_type_name" with a matrix of size defined by the rows and columns in the collection type.

- `Collection.spread sample_list, 'collection_type_name'` - Creates an appropriate number of collections of "collection_type_name" and fills collections with the sample_list.
  The sample list can be Samples, Items, or integers.

### Provisioning Items

Most protocols are performed at the bench, and can be thought of in three phases in which the technician (1) gets the necessary items, (2) does the protocol steps, and (3) disposes of or puts away any items.
One approach to this first and last step is to use a pair of functions, `take` and `release`to provision a list of items. The `take` function instructs the technician to collect a list of items, and the `release` function instructs them to return the items.

For instance, Kapa HF Master Mix is a required ingredient for making PCR Fragments. The following code would instruct the technician to bring an Enzyme Stock containing Kapa HF Master Mix to bench at the `take` command. Then when the protocol is finished, `release ` instructs the technician to put the item back.

From `Cloning/Make PCR Fragment`

```ruby
def main
  ...

  kapa_stock_item = Sample.find_by_name('Kapa HF Master Mix').in('Enzyme Stock')
  take [kapa_stock_item], interactive: true,  method: 'boxes'

  ...
ensure
  release [kapa_stock_item], interactive: true
end
```

`take` and `release` require a list of items as the first argument, which is why we wrap `kapa_stock_item` in brackets.

## Working With Items in Operations

Each instance of a protocol is contained within an `Operation`.
An `Operation` is created by the user in the Aquarium planner as an specific instance of an `OperationType` and then batched together with other `Operations` of the same type into a `Job`, which is then performed by the technician.

As an example: Suppose you have created an `OperationType` with the name "E. coli Transformation." You’ve written all the code you need, and now you’re read to run it.
An `Operation` would be a specific instance of "E. coli Transformation" (the `OperationType`), and a `Job` would be several "E. coli Transformation" `Operations` that have been submitted and are ready to run through the "E. coli Transformation" Protocol as a batch. 

There are two ways to retrieve items within a protocol, and the two methods are called `retrieve` and `take`.
Both of them instruct the technician to retrieve items.

`retrieve` is used on what’s called an `OperationList`, which is exactly what it sounds like — a list of `Operations` being used in a specific job.
`retrieve` has two main purposes. First, it will fetch all of the input `Items` associated with each `Operation` in the `OperationsList` it is called on, enabling us to interact with these items in the protocol code. Next, it will generate show blocks for the tech to instruct them where to go to collect all of these input items, preparing them for the protocol.

Inside a protocol, the `OperationsList` representing all `Operations` in the current `Job` is referred to by the symbol `operations`
To perform a `retrieve`, you would write the following code:

```ruby
class Protocol
  def main
    operations.retrieve
    …
  end
end
```

`take`, on the other hand, takes an argument that’s an array of items, which makes it ideal for retrieving items that aren’t included as explicit inputs in the definition of an operation — e.g., master mix for a PCR, which isn’t something the user should need to explicitly select.

To perform a `take`, you would write something like the following code:

```ruby
class Protocol
  def main
    sample = Sample.find_by_name("pMOD8")
    items_to_retrieve = Item.where(sample_id: sample.id)
    take items_to_retrieve
    …
  end
end
```

This code first finds the sample "pMOD", and then finds all the items that are associated with that sample.
The technician is then instructed to retrieve all of them.

Another important thing both `retrieve` and `take` do is "touch" the item, which allows us to keep a record of all the items used in a job.
This is extremely useful for troubleshooting.

To put items away, you can use `release` (which is used in conjunction with `take` and takes the same arguments) and/or `operations.store` (which is used in conjunction with `operations.retrieve`).

`make` is another important method used on an `OperationsList`. It is used in the same way as `retrieve`, but instead of fetching the existing input `Items` of each `Operation`, it generates new `Items` for the _outputs_ of each `Operation`. `make` does not show instructions to the user on how to create those `Items`... that's what the rest of the protocol is for!

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
        title 'MAKE A REALISH EXAMPLE'
    end
  end
end
```

The `operation_task` helper function defines the tasks for an operation.
Organizing the code this way separates the part of the protocol that operates over all operations from the part that operates over an individual operation.

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
        title 'MAKE A REALISH EXAMPLE'
    end
  end

  def operation_group_2_task(operation_group)
    show do
        title 'MAKE A REALISH EXAMPLE'
    end
  end
end
```

## Protocol Patterns

Most protocol tasks fall into one of three categories:

- Tasks that take input items and use them to create output items,
- Tasks that modify their input items, and
- Tasks that measure their input items, producing files.

### Protocols that Create New Items

The most common form of protocol takes input items and generates output items.
Such protocols will follow these general steps:

1.  Tell the technician to get the input items.
2.  Create IDs for the output items.
3.  Give the technican instructions for how to make the output items.
4.  Tell the technician to put everything away.

We saw earlier that we can write protocols that do these steps at a detailed level, but Aquarium provides functions that will do them over the inputs and outputs of the batched operations.
So, we can write the protocol to manage these tasks relative to the batched operations, which is simpler.

A protocol is able to refer to it's batch of operation using the symbol `operations`, and calls `operations.retrieve`, `operations.make` and `operations.store` to perform the steps above.

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
def operation_task(op)
  show do
    title 'MAKE A REALISH EXAMPLE'
  end
end
```

### Protocols that Measure Items

Another common protocol uses an instrument to measure a sample.
Instruments frequently save the measurements to a file, and so the protocol consists of instructions for first taking the measurement, and then uploading the file(s).

TODO [data associations]

### Protocols that Modify Items

TODO [handling time: timers vs scheduling]

## Writing a Protocol

To use a semi-realistic example, let’s write a simple version of the "E. coli Transformation" protocol from above.
I won’t be going in-depth about all the methods being used, but I’ll leave categorizing each method with the [Method Reference]({{ site.baseurl }}{% link /api/index.html %}) as an exercise for the reader.

Before writing a protocol, it’s always important to ask questions about how you want to structure it, such as:

- Who’s going to be using it?
- Will operations be "batched" together for this protocol? (The answer to this one is usually 'yes'.)
- What input/output structures do I want to use? Items, Collections, an array of items, etc. \* To figure this one out, it’s best to first ask yourself, "What are the pros/cons of doing it a specific way? Which operation types will be wired into this, which operation types will be successors?" A protocol is rarely intended to be used as a standalone — it’s almost always a part of a larger workflow, so it’s important to figure out how you’re going to structure the entire workflow instead of going in all gung-ho, guns a blazin’.

Once you’ve figured out how you’re going to structure it, outlining the protocol is useful.
An outline for the Transform E. Coli protocol is something like the following:

- Check if there are enough comp cells to perform the protocol
- Instruct technician to retrieve cold items needed for transformation
- Label the comp cells
- Electroporate and rescue
- Incubate transformants
- Put away items

First, define what the inputs and outputs are going to be.
This is a transformation protocol — the inputs are going to be comp cells and a plasmid.
Comp cells are best represented as a batch, a plasmid as an item.
The output is going to be a transformed _E. coli_ aliquot — also a plasmid.
So:

![input1]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/19_input_1.png %})

![input2]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/20_input_2.png %})

The "Plasmid" input represents the plasmid — I recommend you take a moment to get over that shocking revelation because there’s something even _more_ shocking coming: The "Comp Cells" input represents the comp cells.

"Plasmid" has multiple sample type / container combinations, because a plasmid can be held in many different containers and you want to give the user as much flexibility as possible. "Comp Cell" only has one sample type / container combination because you only want to use _E. coli_ comp cells, which are all held in the same type of container — a batch.

![output]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/21_outputs.png %})

The output is "Transformed E Coli" with container "Transformed E. coli Aliquot," which will be plated after some incubation period.

This is the first section of the code, going through and trying to figure out whether or not there are enough comp cells for the operation:

```ruby
def operation_task(op)
  comp_cells = op.input("Comp Cells")
  # If current batch is empty
  if comp_cells.collection.empty?
    old_batch = comp_cells.collection

    # Find replacement batches
    comp_cell_id = comp_cells.object_type.id
    all_batches = Collection.where(object_type_id: comp_cell_id).keep_if { |b| !b.empty? }
    batches_of_cells = all_batches.select { |b| b.include? comp_cells.sample && !b.deleted? }.sort { |x| x.num_samples }
    batches_of_cells.reject! { |b| b == old_batch } # debug specific rejection to force replacement
    ...
end
```

This looks like a lot, so let’s break it down.
To understand what’s happening here, the first thing you have to do is understand how a `Collection` is represented in Aquarium.

A `Collection` is represented as a matrix, and looks like the following:

![collections]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/22_collections_example.png %})

Each part of the collection is filled with a "7," which is the sample ID for DH5&alpha;.
In the database, it’s stored like this:

```ruby
[[7,7,7,7,7,7,7,7,7]…[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
```

where "-1" indicates an empty slot.

Because a `Collection` is represented thusly, numerous array methods are used to sort through all collections in Aquarium and find the ones that we’re interested in, which is what all that code above is doing.

```ruby
       # Error if not enough
       if batches_of_cells.empty?
         op.error :not_enough_comp_cells, "There were not enough comp cells of  #{comp_cells.sample.name} to complete the operation."
       else
```

This lets the user know there weren’t enough comp cells of the correct strain (through `comp_cells.sample.name`, which retrieves the sample name of that input) and errors the operation out.

```ruby
        # Set input to new batch
          comp_cells.set collection: batches_of_cells.last

          # Display warning
          op.associate :comp_cell_batch_replaced, "There were not enough comp cells for this operation.            	Replaced batch #{old_batch.id} with batch #{op.input(CELLS).collection.id}"
        end
      end
  end
```

This code sets a new comp cell batch as the "input" (through comp_cells.set) if there are other batches available and lets the user know know through a data association (`op.associate`, which takes in two arguments: the key and upload; here, "comp cell batch replaced" and the message letting the user know a new comp cell was used, respectively).

Data associations are a great tool to pass information through Aquarium.
You can upload messages, measurements, pictures, files, passive-aggressive notes — it’s all good.
Operations, samples, items, etc. all have data associations, which means it’s very easy to attach and retrieve information from all of these.

You also want to detract the comp cell aliquots used from the batch, so the online inventory is accurate.
To do so, there’s a `remove_one` method included in a library, which is used like so:

```ruby
operations.running.each { |op| comp_cells.collection.remove_one comp_cells.sample }
```

Now that any potential operations without sufficient comp cells have errored out, it's time to do a `retrieve` and `make`.

```ruby
operations.running.retrieve(only: ['Plasmid'])
operations.running.make
```

`retrieve` has an optional argument -- you can choose which inputs you want the tech to retrieve using 'only', which takes in an array argument.

```ruby
# Prepare electroporator
show do
  title 'Prepare bench'
  note 'If the electroporator is off (no numbers displayed), turn it on using the ON/STDBY button.'
  note 'Set the voltage to 1250V by clicking the up and down buttons.'
  note ' Click the time constant button to show 0.0.'
  image 'Actions/Transformation/initialize_electroporator.jpg'

  check "Retrieve and label #{operations.running.length} 1.5 mL tubes with the following ids: #{operations.running.collect { |op| "#{op.output("Transformed E Coli").item.id}"}.join(',')}"
  check 'Set your 3 pipettors to be 2 uL, 42 uL, and 300 uL'
  check 'Prepare 10 uL, 100 uL, and 1000 uL pipette tips.'
  check 'Grab a Bench SOC liquid aliquot (sterile) and loosen the cap.'
end
```

This is a show block, letting the tech know to prepare the electroporator and label the tubes. `operations.running` returns a list of all the un-errored operations, and because it returns an `OperationList`, you can use the built-in ruby enumerators on it (e.g., `collect`, `join`, etc.).

Something to get used to, if you haven’t used Ruby before, is method chaining — the practice of putting multiple methods in one line, e.g., `operations.running.collect { … }.join`.
This is the same thing as doing:
`take`, on the other hand, takes an argument that’s an array of items, which makes it ideal for retrieving items that aren’t included as explicit inputs in the definition of an operation — e.g., master mix for a PCR, which isn’t something the user should need to explicitly select.


The next part is to label all the tubes:

```ruby
# Label comp cells
  show do
    title 'Label aliquots'
    aliquotsLabeled = 0
    operations.group_by { |op| op.input("Comp Cells").item }.each do |batch, grouped_ops|
      if grouped_ops.size == 1
        check "Label the electrocompetent aliquot of #{grouped_ops.first.input("Comp Cells").sample.name} as #{aliquotsLabeled + 1}."
      else
        check "Label each electrocompetent aliquot of #{grouped_ops.first.input("Comp Cells").sample.name} from #{aliquotsLabeled + 1}-#{grouped_ops.size + aliquotsLabeled}."
      end
      aliquotsLabeled += grouped_ops.size
    end
    note 'If still frozen, wait till the cells have thawed to a slushy consistency.'
    warning 'Transformation efficiency depends on keeping electrocompetent cells ice-cold until electroporation.'
    warning 'Do not wait too long'
    image 'Actions/Transformation/thawed_electrocompotent_cells.jpg'
  end
```

There’s a new option here — `image`, which allows you to insert an image into the show blocks.

The reason this section of code uses `group_by` (a Ruby method) is to group all the operations by the batch ID being used.
So, each batch will be separated.
Suppose you have ten operations; the first five use batch 1234, the next four use batch 4567, and the last one uses 78910.
This is what the "groups" would look like:

batch 1234: operations 1, 2, 3, 4, 5
batch 4567: operations 6, 7, 8, 9
batch 78910: operation 10

The tech would be told to label the first four comp cells from "1-5"; the `aliquotsLabelled` variable would go up by 5, so the next time the loop is run, it would tell the tech to label the next four comp cells "6-9"; once more, `aliquotsLabelled` would go up (this time by four), and, finally, the tech would be told to label the last comp cell as "10."

Note: If you use this code in the tester interface with randomly generated operations, comp cell inputs will all be generated as part of a single batch, no matter how many operations you have. With this in mind, the expected output on the tester will actually be the tech being told to label all 10 comp cells from 1-10 in a single step.

Now, we need to write the instructions for the actual transformation:

```ruby
1        index = 0
2        show do
3            title 'Add plasmid to electrocompetent aliquot, electroporate and rescue '
4            note 'Repeat for each row in the table:'
5            check 'Pipette 2 uL plasmid/gibson result into labeled electrocompetent aliquot, swirl the tip to mix and place back on the aluminum rack after mixing.'
6           check 'Transfer 42 uL of e-comp cells to electrocuvette with P100'
7           check 'Slide into electroporator, press PULSE button twice, and QUICKLY add 300 uL of SOC'
8            check 'pipette cells up and down 3 times, then transfer 300 uL to appropriate 1.5 mL tube with P1000'
9           table operations.running.start_table
10                .input_item('Plasmid')
11                .custom_column(heading: 'Electrocompetent Aliquot') { index = index + 1 }
12                .output_item('Transformed E Coli', checkable: true)
13                .end_table
14        end
```

This uses a new Aquarium object — `Table`.
The table looks like this:

![table]({{ site.baseurl }}{% link _docs/protocol_developer/images/tutorial_images/23_table.png %})

I’m going to break down the block of code that displays this table, because the rest of the show block is pretty standard.

The `table` (in line 9) is analogous to `note`, `check`, `warning`, etc. in that it’s used as a flag to display the following argument in a certain way.
Without using `table`, your table won’t show up.

Method chaining can be either on the same line, or on multiple lines, too.
So the block of code that says:

```ruby
operations.running.start_table
  .input_item('Plasmid')
  .custom_column(heading: 'Electrocompetent Aliquot') { index = index + 1 }
  .output_item('Transformed E Coli', checkable: true)
  .end_table
```

Is the same thing as `operations.running.start_table.input_item('Plasmid').custom_column(heading: 'Electrocompetent Aliquot') { index = index + 1 }.output_item('Transformed E Coli', checkable: true).end_table`, except a) that doesn’t fit on one line and b) it’s much, much more confusing.
As such, for clarity’s sake, it’s split onto multiple lines.

`start_table` is the method that starts the table. `input_item` adds a column that displays the input item associated with the input "Plasmid." `custom_column` takes in two arguments: One for what heading should be displayed, and the other is a block that determines what will be displayed in each row of the column.
In this case, it’s `index`, which is way to number things 1–n, where n is the number of operations.

`output_item` is exactly like `input_item`, but instead references the output. `end_table` is what signals the end of the table, and to display a table, `end_table` is necessary because that is what returns the fully-formed table.

There are many table methods — refer to the more in depth [Table Method Documentation]({{ site.baseurl }}{% link _docs/protocol_developer/table.md %}) for a full overview.

The next step is to incubate the transformants:

```ruby
 show do
            title 'Incubate transformants'
            check 'Grab a glass flask'
            check 'Place E. coli transformants inside flask laying sideways and place flask into shaking 37 C incubator.'
            #Open google timer in new window
            note "<a href=\'https://www.google.com/search?q=30%20minute%20timer\' target=\'_blank\'>Use a 30 minute Google timer</a> to set a reminder to retrieve the transformants, at which point you will start the \'Plate Transformed Cells\' protocol."
            image 'Actions/Transformation/37_c_shaker_incubator.jpg'
            note 'While the transformants incubate, finish this protocol by completing the remaining tasks.'
        end
```

This also opens up a Google timer for one hour, which is useful.

The last step the tech needs to do is clean up, so:

```ruby
        show do
            title 'Clean up'
            check 'Put all cuvettes into biohazardous waste.'
            check 'Discard empty electrocompetent aliquot tubes into waste bin.'
            check 'Return the styrofoam ice block and the aluminum tube rack.'
            image 'Actions/Transformation/dump_dirty_cuvettes.jpg'
        end
```

We also need to move all the output transformations to the 37C shaker, and we need to do so manually:

```ruby
        operations.running.each do |op|
            op.output("Transformed E Coli").item.move '37C shaker'
        end
```

And that’s it! Not too bad.
Make sure you have the correct number of `end`s, and you can start testing this protocol out on Aquarium immediately.

TIP: While writing a protocol, if you find yourself thinking, "Gosh, I wish there were a method I could use that would do (insert tedious thing here)," chances are, there is — look through the in-depth Aquarium documentation or search for a ruby method through Google.
If there _isn’t_, you can make one yourself and stick it in a library.

## Building Libraries

[saving work with shared functions - include, extend, direct call]

[simplifying with kinds of ducks: using classes]

[things that go awry: show blocks in libraries]
