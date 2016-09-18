The Aquarium Operation Interface
---

Operations are created by the user in the Aquarium planner and then batched together by the lab manager in the Aquarium manager to be sent to a protocol. From within a protocol, it is easy to get a list of the operations that were sent to your protocol with 
```ruby
    operations
```
which returns something like an array of operations. Actually, its a Rails [ActiveRecord::Relation](http://api.rubyonrails.org/classes/ActiveRecord/Relation.html) object extended with a number of Aquarium specific methods, discussed here. Just remember that in addition to what you see here, there are also all the standard array methods (like **each**, **collect**, **select**, ...) and of course the Rails operations (which you probably won't need).

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

This method looks through all of the sample inputs to all of the operations and attempts to find inventory items for them. SIDED EFFECT: If retrieve is unable to find all required items for any given operation, then that operation's status is set to "error" and is skipped (by default) in subsequent operation list methods. The retrieve method then calls **take** (see [Basic Krill](md-viewer?doc=Krill)) on the list of items. The retrieve method takes the following options (defaults listed);

* interactive:true => Whether the to show the user where to find the items
* method:"boxes" => Show the user the freezer box locations. Any value besides "boxes" simply makes the method list locations.

The retrieve method also takes an optional block, which should contain **show** methods, such as **note** or **warning**. For example,

```ruby
operations.retrieve(method:nil) {
  warning "Be careful"
}
```

**make**

**store**

Creating Tables
===

Associating Data
===

