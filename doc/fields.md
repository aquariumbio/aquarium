Field Types
===========

A FieldType is a way of specifying an association of a sample or data with an object. For example, SampleTypes and OperationTypes have field types. As a more specific example, the Fragment SampleType has a field type called "Forward Primer" that specifies what kind of SampleType the Fragment's forward primer is (in this case, it is the sample type Primer). It also has, for example, a Length Sample Type that specifies that a Fragment should have a numerical Length property.

A FieldType ft specifies a type, ft.type, that should be one of the following: "string", "number", "url", "sample", or "item". If ft.type is "sample" then any FieldValue (see below) corresponding to ft should specifiy a sample whose SampleType is one of the SampleTypes specified in the array ft.allowable_sample_types. If it is an item, then the allowable ObjectTypes should be one of the ObjectTypes in the array ft.allowable_object_types.

As an example, the allowable sample types for the Template field of a Fragment can be obtained as follows.

```ruby
SampleType.find_by_name("Fragment").type("Template").allowable_sample_types
```

which returns "Plasmid", "E coli strain", "Fragment", and "Yeast Strain". 