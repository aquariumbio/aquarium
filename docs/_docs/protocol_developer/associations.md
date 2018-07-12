---
title: Data Association Documentation
layout: docs
---
# Data Association Documentation

This is the documentation for how to successfully use data associations to store data related to `Items`, `Collections`, `Plans`, and `Operations`.

See the [API documentation]({{ site.baseurl }}{% link /api/index.html %}) for more details on the functions that Krill provides.

---

## Table of Contents
<!-- TOC -->

- [Data Association Documentation](#data-association-documentation)
    - [Table of Contents](#table-of-contents)
    - [Data Associations](#data-associations)
        - [Setting data](#setting-data)
        - [Getting data](#getting-data)
        - [Example](#example)

<!-- /TOC -->

---

## Data Associations

Data may be associated with `Item`, `Operation` and `Plan` objects.
This data should either be serializable as JSON (e.g., a hash), or be an `Upload` object.

Data associations are managed directly using the `DataAssociation` model.
(The `AssociationMap` class is a wrapper for this model class, making associations easier to use, but hiding some details.)

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
  The value can be any legal combination of hashes, arrays, strings, or numbers.
  The key may be a symbol or a string.
  May be chained.

* `item.get key`: Returns the value of the data assocated with given key.
  May be chained.

* `upload key`: Returns the uploaded data, if any, associated with the given key.
  May be chained.

* `item.notes`: The key `"notes"` (or `:notes`) is reserved for a text valued datum holding a user's textual notes on the object `item`.
  For example, in the sample browser UI, the user may add notes by finding the item and clicking on the notes icon.

### Example

As an example, suppose `item` is an `Item` and `upload` is an `Upload`.
Then one might do

```ruby
item.associate(:row, 12).associate(:col, 14).associate(:image,{},u)
item.notes = "Hello"
item.append_notes " World"
item.associations # => [ row: 12, col: 14, image: {}, notes: "Hello World"]
item.get(:row) # => 12
item.upload(:image) # => <An Aquarium Upload ActiveRecord>
```
