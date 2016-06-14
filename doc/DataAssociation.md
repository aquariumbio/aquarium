Data Associations
===

Objects such as items may have data associated with them via the DataAssociation model. Suppose that p is an object (such as an Aquarium Item). Then the follow methods are available.

Setting data
---

* **p.associate key, value, upload=nil**: Associate value with key. The parameter upload must either not be present, or should refer to a valid, saved Upload object.

* **p.notes= text**: Associate the text field "text" with with p.

* **p.append_notes text**: Append the notes in "text" to the already existing notes (if any).

Getting data
---

* **p.associations**: Returns HashWithIndifferentAccess h where h[key] is the value of the datum for the key. The value can be any legal combination of hashes, arrays, strings, or numbers. The key may be a symbol or a string. May be chained.

* **p.get key**: Returns the value of the data assocated with given key. May be chained.

* **upload key**: Returns the uploaded data, if any, associated with the given key. May be chained.

* **p.notes**: The key "notes" (or :notes) is reserved for a text valued datum holding a user's textual notes on the parent object p. For example, in the sample browser UI, the user may add notes by finding them item and clicking on the notes icon.

Example
---

As an example, suppose *i* is an Item and *u* is an Upload. The one might do

```ruby
i.associate(:row, 12).associate(:col, 14).associate(:image,{},u)
i.notes = "Hello"
i.append_notes " World"
i.associations # => [ row: 12, col: 14, image: {}, notes: "Hello World"]
i.get(:row) # => 12
i.upload(:image) # => <An Aquarium Upload ActiveRecord>
```

