<h1>Reference</h1>


<h2>Relationship Diagram</h2>

![Image of RelationshipDiagram]
(images/references/relationshipdiagram.png)

The Diagram above shows the relationship between all the models in the Aquarium system. 

<h2>Terms</h2>

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
    - i = produce new_collection "Gel", 2, 6: Make an entirely new collection. This creates and takes a new collection object with an empty 2x6 matrix and ObjectType of "Gel". The ObjectType associated with a collection **must** have its handler set to "collection".
    - c = collection_from i: Promotes an Item **i** to a collection.
    - collections = produce spread sample_list , "Stripwell", 1, 12: This call to **spread** returns a list of collections, which is sent to **produce** to take them. If there were 30 samples in **sample_lost**, then the returned list will containt three 1x12 collections, with the first two completely full and the last only half full. The first sample in the list is associated with the first well of the first collection and so on.
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

<h2>Terms Within Aquarium Web UI</h2>

![Image of ItemSearching]
(images/references/SearchingItems.png)

Once you click the inventory tab at the top, you can either click "Basic" to view various ObjectTypes within ObjectType categories, or choose from the following list of SampleTypes.

![Image of SampleSearching]
(images/references/SearchSample.png)

Here is an example of the page you encounter after clicking on "Fragments" on the drop down menu. The far left column shows you the Sample ID and the column next to that gives you the Sample name. You can click on the ID to see the Sample in detail.

![Image of ItemExample]
(images/references/SampleSpec.png)

At the top, the SampleType, Sample ID and Sample Name are shown. On the left side, there is a list of all the ObjectTypes (or Containers) that can be associated with this Sample. The number next to the ObjectType represents the number of Items of the given Sample that exist in that specific ObjectType. The three columns in the middle show the Item ID, Item Location, and Item Data. 

<h2>Analogy for the model system in Aquarium</h2>

A simple way for someone without a strong biology background can roughly think of the system in this way:
  - Item: This is yourself. You are a specific person with Data: "Height = 5'9", "Weight" = 160 pounds, etc. and Location = "1234 Elm St."
  - ObjectType: This is all the different kinds of role you play in society: "Student", "Parent", "Worker". You are still you, but in different forms
  - Sample: This is 
  - SampleType:
  - Collection: This can be the local rock band you are a part of. The band itself is a single entity with 
