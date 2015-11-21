# Workflow Protocols

## Getting an Operation Object

The input to a protocol in the workflow framework is a JSONable object containing information about the inputs, outputs, parameters, data, and exceptions in the workflow. To manage this information, and all the information associated with the protocol, an object of type *Op* is created at the beginning of every protocol as follows:

```ruby
o = op input
```
    
The object *o* is then used throughout the protocol. The reason the letter "o" is used here is for the sake of brevity. The operation *o* is used mainly through method chaining. For example, you might write

```ruby
o.input.all.take
```

which works as follows. The *input* method tells *o* that later method calls should refer to the input to the operation. It returns an object of type *Op* as well. The *all* method then selects all inputs (as opposed to one particular input). It also returns an object of type *Op*. Finally, the *take* method tells interacts with the user, telling her/him where to find all the inventory specified in the inputs. These methods are explained in detail below.

## Selecting Parts of the Operation

An operation has inputs, outputs, parameters, and data. To tell the operation which parts of it subsequent methods will refer to, use one of the following

```ruby
o.input
o.output
o.parameter
o.data
```

Whatever selection shows up last takes precedence. So 

```ruby
o.input.output
```

Selects the output, ignoring what the previous selection of input.

Each input, output, parameter, or data has a name, which shows up in the workflow diagram. To select a particular named part, use the name of the part. For example, if an operation has an input named *fwd*, you can select it as in

```ruby
o.input.fwd
```

If the operation has another input named *rev*, you can select both *fwd* and *rev* as in

```ruby
o.input.fwd.rev
```

Finally, you can select all input or all output parts as in

```ruby
o.input.all
```

Or

```ruby
o.output.all
```

## Options

Options set particular flags for latter inactions with an *Op*. Presently, the following options for the *take*, *produce*, and *release* methods, discussed below, are available.

```ruby
o.query(bool)		# => whether to query the user about which item to take
o.silent(bool)      # => whether to take, produce or release silently (without user interaction)
o.method(string)    # => what method to use with take and release (e.g. "boxes")
```

For example, to silently release the items associated with the output named #fragment# you would do

```ruby
o.output.fragment.silent(true).release
```

## Getters

Once inputs, outputs, parameters, data, options, and names have been specified, there are a number of methods for getting the actual values of the specified parts. For input and output, you can use the following

```ruby
sample_ids   # => a list of sample ids
item_ids     # => a list of item ides
samples      # => list of Sample objects (expensive db operation!)
items        # => list of Item objects (expensive db operation!)
Containers   # => list of ObjectType (e.g. Container) objects (expensive db operation!)
```

For example, suppose an operation has a shared input called *ladder* that specifies a parrticular DNA Ladder to use for the operation Then you would do

```ruby
o.input.ladder.samples.first
```

to get the Sample object corresponding to the ladder.

Sometimes you just need the length of the selection, for which you can use *length*, as in

```ruby
o.output.fragment.length
```

which returns the number of inventory specifications in the selection.

## Inventory Specifications

```ruby
associate
sample_id
item_id
container_id
collection_id
row
column	
```

## Threads

The input, output, data, and parameter vectors of non-shared components of a workflow are all indexed the same way, from 0 to one minus the number of threads in the operation. Another way to group the components is, thus, by thread. For example, suppose that an operation has an input named u, a paramter named p, and an output named y. Then you can use something like the following code to iterate over all the threads.

```ruby
show do 
  o.threads.each do |thread|
    note "Thread #{thread.index}: "
      + "#{thread.input.u.sample_id}, #{thread.parameter.p} => #{thread.data.y.sample_id}"
  end
end
```

The return value of o.threads is a *ThreadArray* object, which is a Ruby Array of *WorkflowThreads*, extended with some extra methods, described below.    

The variable *thread* in the above is a *WorkflowThread* object. It has method-chaining selectors similar to *Op*: input, output, parameter, and data. Once a selector is indicated, you can use the name of the input, output, or wahtever to access that part of the thread. These accessors return *InventorySpecification* objects.

A WorkflowThread also responds to *index*, which returns which thread it is. 

You often need to transfer a number of samples into a set of collections. To do this, use the *spread* method of ThreadArray. For example, say *stripwells* is a CollectionArray. Then you can do:

```ruby
o.threads.spread(stripwells) do |thread,slot|
  thread.output.fragment.associate slot
end
```

In this case, the result is that the output fragments are associated with the collection slots in the stripwells. You can add the option 

```ruby
skip_occupied: true
```

to the *spread* method to make it skip over occupied slots in the collections.

## Tables

In Krill, tables are just arrays of arrays. The *Table* class makes it easy to construct them. To declare a table, you define its column names and headings. For example, 

```ruby
t = Table.new x: "The value of x", y: "The value of y"
```

You can then build a table by appending rows. For example, 

```ruby
t.x(1).y(2).append
t.x(3).y(4).append
```

and then render it as in

```ruby
show do
  table t.choose([:x,:y]).render
end
```

The argument to choose is an array of the columns you would like to appear in the table. You can also set limits on which rows to render as in, for example

```ruby
t.from(0).to(1).choose([:y])render	
```

which renders the first row, and only the :y column.

If you want to add columns after initialization, you can do

```ruby
t.column(:z,"The value of z")
```

for example.

## Collections

If an input or output is specifed as a collection (because its Container has a collection handler), then it will be instantiated with one or more actual collections. Collections are typically also specified as being shared by some number of threads. For example, a gel might have 20 lanes. Two of the lanes are used for a DNA ladder, so that 18 lanes are left for samples. Thus, in the *gel* input to a "Run Gel" protocol would be shared with 18 threads. If the workflow were run with 50 samples, then ceiling(50/18) = 3 gels would be needed. A class called *CollectionArray* is used to manage such an array of collections. To get the collection array for an input or output, do something like the following.

```ruby
c = o.input.gel.collections
```

which will return the set of collections being input to the operation. Each collection in the list is a *Collection* object (see Krill documentation). Continuing with the gel example above, to put ladder DNA in two of the lanes of the gel, do:

```ruby
o.input.gel.collections.each do |gel|
	gel.set 0, 0, lid
  gel.set 1, 0, lid
end
```

when lid is the id of the ladder sample being used. 
	
	
	
	
