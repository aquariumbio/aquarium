<h2>References</h2>

- **Item**
  - The physical item that exists in the lab. For an Item **i**: 
    - i.id: Identification number for that particular item. Every item in the lab has an associated ID number that can be used to find
    information about that particular item.
    - i.location: String representation of where the item is located within the lab.
  	- i.object_type_id: The object type ID associated with the item.
  	- i.object_type: The object type associated with the item.
  	- i.sample: (If exists) Corresponding sample for the item.
  	- i.datum: Associated data with the item. Usually a hash. To set datum to new value do as follows: "i.datum = x", where x is the
    new data.
  	- i.save: Save any changes made to the item.
  	- i.reload: Load the current information about the item.
  	- i.mark_as_deleted: Use this method to delete the item. This way, old logs that have used this item can still have a reference to it.

- **Container / ObjectType**
  - This is the object type of the item. For an ObjectType **o**:
    - o.name: Returns name of the object type.
    - o.handler: returns the classifier for the item's object type. Aquarium uses this to categorize object types with the same classifier as "Collections".

- **Sample**
  - A specific sample. For a Sample **s**:
    - s.id: Identification number for the given sample.
    - s.name: Name of sample.
    - s.sample_type_id: Sample type ID of the given sample.
    - s.properties: Key-value pair hash where the nth key is named according to s.sample_type.fieldnname (as a symbol, not string). Format: 
    {key1:value1, key2:value2, key3:value3...}
    - s.make_item_object_type_name: Returns an item associated with the sample and in the object type described by object_type_name. The location is handled by the location wizard.

- **SampleType**
  - Defines a class of samples that all have the same basic properties. For a SampleType **st**:
    - st.name: Name of the sample type.
    - st.fieldnname: Name of the nth field (n=1,2....8).
    - st.fieldntype: Type of the nth field ("number", "string", "url", or "sample"). See Sample object to see how to use these fields.

- **Collections**
  - Special kind of Item that has a matrix of Sample IDs associated with it. This matrix is stored in the datum field of the item in this form: { matrix: [ [ ... ], ..., [ ... ] ], ... }. Aquarium provides the class Collections, which inherits from Item
    - i = produce new_collection "Gel", 2, 6: make an entirely new collection.
    - c = collection_from i: promotes an Item **i** to a collection.
  - For a Collection **c**: (Collections inherits all of the methods of item plus the additional methods listed below)
    - c.apportion r,c: Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database. The old matrix associated with the collection is lost.
    - c.matrix: Returns the matrix associated with the collection.
    - c.matrix = m: Sets the matrix associated with the collection to the matrix of Sample IDs **m**. The old matrix is lost.
    - c.associate m: Sets the matrix associated with the collection to the matrix m where m can be a matrix of Samples of matrix of Sample IDs. Only sample IDs are saved to the matrix. The old matrix is lost. 
    - c.set r,c,s: Set the r,c entries of the matrix to the ID of the Sample **s**
    - c.next r, c, opts={}: Returns the the indices of the next element of the collections. Skips to the next column or row if necessary. With opts={skip_non_empty: true}, returns the next non empty indices. Returns nil if [r,c] is last element of collection.
    - c.dimensions: Returns the dimensions of the matrix associated with the collection.
    - c.num_samples: Returns the number of the non empty slots of the matrix.
    - c.non_empty_string: Returns a string representing the indices of the non empty elements in the collection. Example: can return "1,1 - 5,9", which means that the collection contains samples in those indices. The string representation starts at 1, not 0. 


<h1>Relationship Diagram</h1>
