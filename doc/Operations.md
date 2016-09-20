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

**store**

This method produces instructions for the technician to follow to return inputs and or outputs of a protocol to their proper place in the lab (e.g. a freezer). You can specify **interactive: true** and  method: "boxes" as with *retreive**. You can also specify whether to store the input inventory with **io: "input"** (the default) or the output inventory with **io: "output".

Creating Tables
===

The **operations** list makes it easy to construct tables, with a number of methods that operate on or return [Table](md-viewer?doc=Tables) objects. For example, the following code builds a table that includes item ids, collections, rows, columns, and custom columns.

```ruby
operations.retrieve
          .make

t = operations.start_table
      .input_item("Forward Primer")
      .input_item("Reverse Primer")
      .custom_column("Master Mix (uL)") { |op| 50 }
      .output_collection("Fragment")
      .output_row("Fragment")
      .output_column("Fragment")
      .end_table

show do
  title "Ingredients Table"      
  table t.all.render
end
```

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
                  .custom_column("Concentration") { |op| op.input_data "Plasmid", :concentration }
                  .end_table
    
    show { table t.all.render }
    
    operations.store(io: "input", interactive: false)

    return {}
    
  end

end
```

