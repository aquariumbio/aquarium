The Aquarium Operation Interface
---

Operations are created by the user in the Aquarium planner and then batched together by the lab manager in the Aquarium manager to be sent to a protocol. From within a protocol, it is easy to get a list of the operations that were sent to your protocol with 
```ruby
    operations
```
which returns something like an array of operations. Actually, its a Rails [ActiveRecord::Relation](http://api.rubyonrails.org/classes/ActiveRecord/Relation.html) object extended with a number of Aquarium specific methods, discussed here. Just remember that in addition to what you see here, there are also all the standard array methods (like **each**, **collect**, **select**, **reject**, ...) and of course the Rails operations (which you probably won't need).

Iterating Through Operatons
===

To iterate through all operations, simply use the standard Ruby array method **each**, as in the following. 
```ruby
operations.each do |op|
  # Do something with op here
end
```
You can also specify whether to iterate over running or errored operations, and use select, reject, and collect operations. For example, to collect all running operations whose "Template" input has a concnentration greater than 100 nM, do the following.
```ruby
my_ops = operations.running.select do |op|
  op.input_data("Template", :concentration) > 70.0
end
```

You can group operations which can be useful 
if you want to display a show block for a unique item, sample, or collection.

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

Checking and Changing Operation Status
===

Each operation **op** has a status, **op.status**. When a protocol first starts, the status should be "running". When the protocol completes, Aquarium automatically sets the status to "done". If for some reason an operation has a problem, your protocol can set the status to "error" as in
```ruby
op.set_status "error"
```
which sets the status and saves the operation. Subsequent calls to **operations** can be filtered by doing **operations.running** or **operations.errored**. Note that table operations **operations.start_table...** described below default to running operations.

It is common to provide the owner of the operation some information about why you are setting their operation's status to "error". You can do this with something like
```ruby
  op.set_status "error"
  op.associate :no_growth, "The overnight has no growth." 
```
or with the shorthand
```ruby
  op.error :no_growth, "The overnight has no growth." 
```


Retrieving, Making, and Storing Inventory
===

Almost all protocols in Aquarium have the same basic form:

* Tell the user to get the required inventory (retrieve).
* Create item ids for the inventory items that will be produced (make).
* Give the users step by step instructions for how to make the produced items (show).
* Put everything away (store).

A skeleton protocol that does just that is as follows.

```ruby
class Protocol
  
  def main

    operations.retrieve
    operations.make

    show do
      title "Instructions here"
    end

    operations.store

  end

end
```

The methods retrieve, make, and store are described next.

**retrieve**

This method looks through all of the sample inputs to all of the operations and attempts to find inventory items for them. **Note:** If retrieve is unable to find all required items for any given operation, then that operation's status is set to "error" and is skipped (by default) in subsequent operation list methods. The retrieve method then calls **take** (see [Basic Krill](md-viewer?doc=Krill)) on the list of items. The retrieve method takes the following options (defaults listed);

* interactive:true => Whether the to show the user where to find the items
* method:"boxes" => Show the user the freezer box locations. Any value besides "boxes" simply makes the method list locations.

The retrieve method also takes an optional block, which should contain **show** methods, such as **note** or **warning**. For example,

```ruby
operations.retrieve(method:nil) {
  warning "Be careful"
}
```

**make**

This method creates inventory items and/or collections for the output associated with the operations. Outputs can either be stand alone items or parts of collections. The I/O definition page for an operation type has a checkbox labeled **part?** for whether an output is a part. For such outputs, **make** creates a new collection and assigns output samples to spaces in that collection. 

Once **make** has been run, an operation's inventory can be found via the **outputs** method, as in
```ruby
operations.make

operations.each do |operation|
  operation.outputs do |output|
    # do something with output.child_item here if standalone item
    # do something with output.collection, output.row, and output.column if output.part? is true
  end
end
```

If only some of the outputs need to be made, use the only option as, for example, in
```ruby
operations.make only: ["Plasmid"]
```

If an output item is simply the same as the input item, and no new item item needs to be made, use pass, as in
```ruby
operations.each do |op|
  op.pass("Plasmid")
end
```

or, if the input and output have different names, do for example:
```ruby
operations.each do |op|
  op.pass("Plasmid", "Another Plasmid")
end
```

If an output of an operation is a part, then **make** will create new collections to put the outputs in. For example, say 26 operations are being processed and they have an output part that should be put into a 3x4 collection. Then three collections will be made, and the outputs of the operations will fill up the first two collections, and two wells of the third collection. After running **make**, you can retrieve a hash of the collections created with 
```ruby
operations.output_collections
```
which is index by the name of the output. For example, operations.output_collections["Fragment"] would give a list of collections into which the "Fragment" outputs were placed.

Sometimes you need to make more parts of a collection than you have operations. For example, if you need to reserve some lanes of a gel for ladder. In that case, you can insert a VirtualOperation to your operations list, and then make. For example, Lets say you have n 2x6 gels and want to not associate any operation with lanes 0,0 and 1,0. Then you could do 
```ruby
(0...n/6).each do |m|
  insert_operation 6*m, VirtualOperation.new
end
operations.make
```
In this case, make will skip parts of the output collections associated with the new virutal operations. If you use this feature, make sure to insert the virtual operations just before you call make, as other methods that action on the operations may be affect. If you need to use the operations list after inserting, you can use op.virtual? to check whether an operation is virtual.

Note that you an also make individual operations, instead of the whole list. For example, given an operation op, you can call
```ruby
op.make
```
or if op is to be the (2,3) part of a collection c, you can call
```ruby
op.mark_part(c,2,3)
```

**store**

This method produces instructions for the technician to follow to return inputs and or outputs of a protocol to their proper place in the lab (e.g. a freezer). You can specify **interactive: true** and  method: "boxes" as with *retreive**. You can also specify whether to store the input inventory with **io: "input"** (the default) or the output inventory with **io: "output".

Creating Tables
===

The **operations** list makes it easy to construct tables, with a number of methods that operate on or return [Table](md-viewer?doc=Tables) objects. For example, the following code builds a table that includes item ids, collections, rows, columns, and custom columns.

```ruby
operations.retrieve
          .make

show do
title "Ingredients Table"      
table operations.start_table
  .input_item("Forward Primer")
  .input_item("Reverse Primer")
  .custom_column(heading: "Master Mix (uL)") { |op| 50 }
  .output_collection("Fragment", heading: "Frag")
  .output_row("Fragment")
  .output_column("Fragment")
  .end_table
end
```

The methods available for making tables this way are

```ruby
input_item        
output_item       
input_sample      
output_sample     
input_collection  
output_collection 
input_row         
output_row        
input_column      
output_column  
```

All of these methods take the input or output name as an argument, and take the options

```ruby
heading: "A string to use instead of the default"
checkable: "Whether the table entry should be checkable by the technician"
```

In addition, you can make custom columns via

```ruby
custom_column { |op|
  # code that uses op to compute a number of string here
}
```

You can pass a heading: and/or a checkable: option to custom_column.

To show a column of data entry cells for the technician to fill out, use the following

```ruby
show do 
    table operations.start_table
      .get(:x, type: 'number', heading: 'Enter a value in this column', default: 1)
      .end_table
end
```

After this show is complete, this data can be retrieved from an operation op via op.temporary[:x].
You can of course use any symbol, not just :x. To show a table of operation data, do

```ruby
show do
  table operations.start_table
    .result(:x, heading: "You entered this data")
    .end_table
end
```

Inputs and Outputs
===

Given an operation **op**, you can access its inputs and outputs by name using the **input** and **output** methods, which return what are called FieldValue objects. The FieldValue objects then have a number of methods that allow you to determine what inventory items, samples, and object_types are associated with the field the input or output. For example, suppose op has an input named "Primer". You can then access the following methods:

```ruby
op.input("Primer").item
op.input("Primer").sample
op.input("Primer").collection
op.input("Primer").sample_type
op.input("Primer").object_type
```

The same foes for *op.output*. These methods will return nil if the requested object is not found. 
Otherwise, you'll get an ActiveRecord for an Item, Sample, SampleType, or ObjectType, respectively.

If an input (or output) is an array, you can get an array of values using

```ruby
op.input_array("Primer")
```
which returns an Array-like object with the following methods for access items, samples, etc:
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
The same goes for *op.output_array*.

If an input is a parameter, for example called "X", you can get the value of the parameter for that operation:
```ruby
op.input("X").val
```
The 'val' method will return a value of the defined type for the parameter. 

Paramters can be numbers, strings, or json. If the paramter is of type json then

  op.input(“x”).val

will return a Ruby object with the same structure as the json, and with symbols (not strings) for keys. Note that if the json does not parse, you will get an object of the form.

  { error: “JSON parse error description”, original_value: “whatever you put as the input” }.

Adding Inputs After the Protocol has Started
===
Note that for the items associated with an operatioj to be tracked, the have to be inputs or outputs. Sometimes, however, you don't know what items a protocol will use ahead of time, or do not need the user to specify them in the planner. In this case, you can add an input online using op.add_input as in the following code:

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

Here, we know we want the protocol to always use the specified primer (a contrived example), so it is hard coded. But which item is used is determied by op.add_input. The chosen item is the return value and should be checked for non-nil, meaning the method found an item.

Data Associations
===

You can associate data with operations, or with the items associated with operations. These will show up in different places when the user goes looking for them. For example, if you associate data with an operation, the user will find it when looking through an executed plan. If you associate the data with an item, then the suer will find it when they go looking for their items in the sample browser. 

To work with data associations for an operation, you can user the [Data Associations](md-viewer?doc=DataAssociation) methods. Read that documentation and assume that **p** in the first paragraph is an operation, such as might be found in the middle of an **operations.each** block.

To work with data associations for inputs and outputs of operations, Aquarium provides the convenience routines **input_data**, **output_data**, **set_input_data**, **set_output_data**. For example, 
```ruby
op.set_input_data "Plasmid", :concentration, 123.4 # sets the concentration 
                                                   #of the input plasmid to 123.4
c = op.output_data "Fragment", :concentraton       # returns the concentration of 
                                                   # the output plasmid
```
Here is a more complete example. Assume that the operation type associated with this protocol has a an input called "Plasmid". Then here is a way to ask the user to input concentrations for each plasmid, and then display what they entered in a table.

```ruby
class Protocol

  def main

    operations.retrieve(interactive: false)
    
    operations.running.each do |op|
    
        user_input = show do 
            title "Enter a value"
            get "number", var: :concentration, label: "Enter a number", default: rand(1000)/10.0
        end
        
        op.set_input_data "Plasmid", :concentration, user_input[:concentration]
    
    end
    
    t = operations.start_table
                  .input_item("Plasmid")
                  .custom_column(heading: "Concentration") { |op| op.input_data "Plasmid", :concentration }
                  .end_table
    
    show { table t.all.render }
    
    operations.store(io: "input", interactive: false)

    return {}
    
  end

end
```

