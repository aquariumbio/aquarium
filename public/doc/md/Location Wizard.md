Location Wizards
================

A location wizard is a bit of code that uses a schema to store new items. For example, Primers might be stored in a -20C freezer in 81 slot freezer boxes stored on shelves that contain 16 boxes. A location wizard for this scheme would have locations of the form M20.x.y.z where x is the shelf (or hotel as we call them in the Klavins lab), y is the box, and z is the slot in the box. 

A wizard works by setting up a table of all locations with the specified form that have evern been used. When a new item is made, the wizard finds the lowest available location for that item. Here W.x.y.z < W.X.Y.Z if x < X, or x=X and y<Y, or x=X and y=Y, and z<Z. If all available locations are taken, then wizard computes the next new location, adds it to the table of locations, and puts the item there. 

### Defining a New Wizard

The interface for creating a new location wizard can be found under the Inventory menu. There you can click "New Wizard". The wizard name shoudl be short, such as "M20" as it will be used as the first part of the location. The description can be a sentence or so. The field names are used to remind the user what each field means. In the example above, we would use "Hotel", "Box", and "Slot". The capacity for the second two fields can be a finite, positive number. In the above example, we would use 16 for the Box field and 81 for the Slot field. The first field is always assumed to have infinite capacity (meaning you can go buy more freezers as you need them).

### Associating a Wizard with an Object Type

Go to the object type's edit page, or new page if you are creating a new object type, and enter the name of the wizard in for the "Location Prefix" field. All new items with that object type will use the wizard associated with that name, if there is one defined. Note that multiple object types can use the same wizard. For example, we store Primer Aliquots, Primer Stocks, Plasmid Stocks, etc. in the same type of freezer box.

### Moving Items

In both the sample page and the item page, you can enter in a new location for an item. If the location has the form of a wizard location, then it must be empty for you to move the item there, otherwise Aquarium will not let you move it. You can also set the location to some other string, such as "Bench". Doing so will take the item out of the wizard's control. You can also put it back under wizard control by moving it to an empty location of the form managed by the associated wizard.

### Krill Interface

Suppose **i** is an item, **W** is the name of a wizard, and **W.1.2.3** is an initially empty location.

This code returns the location of the item.

```ruby
i.location
```

To move the item, do:

```ruby
i.move_to "W.1.2.3"
```

Note that the above code saves the item. However, you may want to do i.reload after this and other location calls to make sure that all associations are updated. If the above call fails, you can see the error messages with the standard rails ActiveRecord error interface.

```ruby
i.errors.full_messages.join(', ')
```

To set the location of the item to something out of the scope of the wizard, do:

```ruby
i.location = "Bench"
```

To return the item to a wizard location, do:

```ruby
i.location = "W.1.2.3"
```

Note that you should only use the above if the item is not being managed by the wizard. If **i** is managed by a wizard and you do i.location = "W.1.2.3", then the old location for **i** will not be released. 

If you do not have a particular location in mind, it is probably better to do

```ruby
i.store
i.reload
```

in which case the wizard will find the lowest available location. Use **i.location** to see where the item was stored.

To delete an item, do

```ruby
i.mark_as_deleted
```

which does not remove the item, but just removes any location information (i.e. the item isn't **anywhere**, so it must not exist). You can check to see if an item is deleted with

```ruby
i.deleted?
```

and you can restore the item by doing **i.store**, which will put it in a wizard-managed location again.










