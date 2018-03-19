# Data Associations

Data may be associated with `Item`, `Operation` and `Plan` objects.
This data should either be serializable as JSON (e.g., a hash), or be an `Upload` object.

This is supported by the `DataAssociation` model in Krill, but the standard library also provides the `AssociationMap` class that hides some details.
Both are described here.

## AssociationMap

An `AssociationMap`  manages the data associations for an item, operation or plan.
The class is available as a standard library and must be imported using

```ruby
needs "StandardLibs/AssociationManagement"
```

The class can then be included directly into a protocol or library, or referenced directly.

A map is associated with an object using the initializer.
For instance, for the `Item` reference `item` the command

```ruby
map = AssociationMap.new(item)
```

creates a new `AssociationMap` that includes any data already associated with the object `item`.

To add a new association, use

```ruby
map.put(key, data)
```

where `data` may be a serializable or `Upload` object.

Objects can then be retrieved by the key value using

```ruby
map.get(key)
```

The associations in the `AssociationMap` must be explicitly saved to the database with

```ruby
map.save()
```

otherwise, the data will not be accessible later.

## DataAssociation

Data associations are managed directly using the `DataAssociation` model.
(The `AssociationMap` class is a wrapper for this model class, making associations easier to use, but hiding details.)

Using an `Item` reference `item` as an example, the following methods are available:

### Setting data

* `item.associate(key, value, upload=nil)`:
  Associate `value` with `key`.
  The parameter upload must either not be present, or should refer to a valid, saved `Upload` object.

* `item.notes= text`: Associate the text field `"text"` with `item`.

* `item.append_notes text`: Append the notes in `"text"` to the already existing notes (if any).

### Getting data

* `item.associations`:
  Returns `HashWithIndifferentAccess` `h` where `h[key]` is the value of the datum for the key.
  The value can be any legal combination of hashes, arrays, strings, or numbers. The key may be a symbol or a string. May be chained.

* `item.get key`: Returns the value of the data assocated with given key. May be chained.

* `upload key`: Returns the uploaded data, if any, associated with the given key. May be chained.

* `item.notes`: The key `"notes"` (or `:notes`) is reserved for a text valued datum holding a user's textual notes on the object `item`. For example, in the sample browser UI, the user may add notes by finding the item and clicking on the notes icon.

### Example

As an example, suppose `item` is an `Item` and `upload` is an `Upload`. Then one might do

```ruby
item.associate(:row, 12).associate(:col, 14).associate(:image,{},u)
item.notes = "Hello"
item.append_notes " World"
item.associations # => [ row: 12, col: 14, image: {}, notes: "Hello World"]
item.get(:row) # => 12
item.upload(:image) # => <An Aquarium Upload ActiveRecord>
```
