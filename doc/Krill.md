Authoring Protocols for Aquarium
===

Prerequisites
---
To author a protocol for Aquarium, you should

* Have access to an Aquarium server, preferably a rehearsal server where mistakes don't matter.
* Have access to a github repository that the Aquarium server can see when you choose "Protocols > Under Version Control" from the menu.
* Understand enough about github to be able to create a new file, edit it, and save it.
* Know a bit of the Ruby programming language. Check out the [Ruby Page](https://www.ruby-lang.org/en/) for documentation.


Getting Started
---
Here is very a simple protocol that displays "Hello World!" to the user.

	class Protocol
	
		def main
			show {
				title "Hello World!"
			}
		end
		
	end
	
Save this protocol and run it from within Aquarium. It should display a page to the user that says "Hello World!" and a "Next" button. When the user clicks next, the protocol will complete. 

The above example illustrates several important aspects shared by all protocols.

First, the code is all wrapped in a class called **Protocol**. Aquarium looks for this class when it starts the protocol. You must define it, otherwise you will get an error when you run the protocol. Of course, you can define other classes and modules as well, and call them whatever you want to call them. 

Second, the method **main** is defined within the  **Protocol** class. This method is Aquarium's entry point into your protocol. You can of course define other methods as well. However, the names **main**, **arguments**, and **debug** have special meaning (see below).

Third, **show** is a function made available to your code by Aquarium. It takes a Ruby block (denoted by curly braces, or by **do ... end** if you wish). Within the block, there are a number of functions that are available, including the function **title**, which takes a string as an argument. The **show** function is how you communicate with the user running your protocol. It is a blocking call, meaning that your code stops running until the user clicks "Next" from within Aquarium. You might think of it as simultaneous "puts" and "gets" calls. You can have any number of calls **show** in your code and you can put fairly complex stuff into the show block.

All About Show
===

The **show** function takes a block of code that can call the following functions:

**title s**

Put the string s at the top of the page. Usually only called once in a given call to show.

**note s**

Put the string s in a smaller font on the page. Often called several times.

**warning s**

Put the string s in bold, eye catching font on the page in hopes that the user might notice it and heed your advice.

**bullet s**

Put a thie string s on the page, with a bullet in front of it, as in a bullet list.

**check s**

Put a thie string s on the page, with a clickable checkbox in front of it.

**image path**

Display the image pointed to by **path** on the page. The **path** argument should be understood by whatever image server you have configured for your installation of Aquarium.

**get type, opts={}**

Display an input box to the user to obtain data of some kind. If no options are supplied, then the data is stored in a hash returned by the **show** function with a key called something like get_12 or get_13 (for get number 12 or get number 13). The name of the variable name can be specified via the **var** option. A label for the input box can also be specified. As an example,

	data = show {
      title "An input example""
      get "text", var: "y", label: "Enter a string", default: "Hello World"
      get "number", var: "z", label: "Enter a number", default: 555
    }
    
    y = data[:x]
    z = data[:z]
    
**select choices, opts={}**

Display a selection of choices for the user. The options are the same as for **get**. For example,

	data = show {
      title "A Select Example"
      select [ "A", "B", "C" ], var: "choice", label: "Choose something", default: 1
    }
    
    choice = data[:choice]

**separator**

Display a break between other shown elements, such as between two notes.

**item i**

Display information about the item i -- its id, its location, its object type, and its sample type (if any) -- so that the user can find it. See "Items and Samples" below.

**table t**

Display a table represented by the matrix t. For example, 

	show {
	  table [ [ "A", "B" ], [ 1, 2 ] ] 
	}

shows a simple 2x2 table. The entries in the table can be strings or  integers, as above, or they can be hashes with more information about what to display. For example, 

	m = [
	  [ "A", "Very", "Nice", { content: "Table", style: { color: "#f00" } } ],
	  [ { content: 1, check: true }, 2, 3, 4 ]
	]

    show {
      title "A Table"
      table m
    }
    
shows a table with the 0,3 entry has special styling (any css code can go in the style hash) and the 1,0 entry is checkable, meaning the user can click on it and change its background color. This latter function is useful if you are presenting a number of things for the user to do, and want to have them check them off as they do them.

**transfer a, b, routing**

You will need to read about "Collections" below before this function makes sense. The **transfer** function show an interactive transfer display to the user. The arguments **a** and **b** should be collections and **routing** should be an array of routes of the form { from: [a,b], to: [c,d], volume: v }. Here a,b,c, and d are integer indices into the collections a and b respectively. The "volume" key/value pair is in microliters and is optional. If no volume is specified, then it is expected that the user transfer all of the contents of the source well. 

Input via Arguments
===
To specify arguments (a.k.a. parameters) to a protocol, define the method **arguments** in the **Protocol** class. The arguments are then available from within the protocol via the **input** method. For example,

	class Protocol

	  def arguments
	    { x: 1, y: "name" }
	  end

	  def main
	
	    x = input[:x]
	    y = input[:name]
	    
	    show {
	    	title "Arguments"
	    	note "x = #{x}, y = #{y}"
	    }
	    
	  end
	  
	end
	
The keys in the hash returned by the **arguments** method define the names of the arguments. The default values for the arguments are values in the hash. They are presented to the user as defaults, but the user can overwrite them. Once the protocol starts running, the values passed in by the user are available via the **input** method. For technical reasons, the **input** method is not available from within a show block, so in the above code the arguments are extracted and assigned to local variables so they can be shown to the user.

**Note**: The arguments method merely defines what is displayed to the user when the protocol starts and limits the user to setting only the arguments specified. However, if the protocol is started via a metacol, for example, then the arguments availble via the input method can be ay arbitrary hash or array containing integers, strings, arrays, and other hashes.

Output via Return
===

For a protocol to return values to, for example, the metacol that called it, simply return a value from the main method. Note that in Ruby, methods return whatever value the last line of the method produces. So if you do not explicitly return something you might be returning nonsense. For example, here is a protocol that asks the user for a value and returns that value plus one.

	class Protocol
	
		def main
		
			user_input = show {
              get "number", var: "x", label: "Enter a number", default: 0
		    }
    
    		return { y: user_input[:x] + 1 }
    		
    	end
    	
     end

A common pattern in protocols is to merge a hash obtained from the input to the protocol with more infomation. For example,

	class Protocol
	
	  def main
	  
	    x = input
	    
	    # Your code here wherein a variable y is computed based on,
	    # for example, input obtained from the user as (s)he runs 
	    # the protocol or sample ids read from the inventory database.
	    
	    return x.merge y
	    
	  end
	  
	end
	
The output of this protocol can then be fed to another protocol that adds even more information to its input. 

Items, Objects and Samples
===
The Aquarium inventory is managed via a structured database of Ruby objects with certain relationships, all of shich are available within protocols. The primary inventory objects are

* **ObjectType**: An object type might be named a "1 L Bottle" or a "Primer Aliquot". If the variable **o** is an ObjectType, then the following methods are available:* 
  * o.name - returns the name of the object type, as in "1 L Bottle"
  * o.handler - returns the name that classifies the object type, as in "liquid_media". This name is used by the aquarium UI to categorize object types. The special handler "collection" is used to show that items with this given object type are collections (see below)   
* **SampleType**: A sample type might be something like "Primer" or "Yeast Strain". It defines a class of samples that all have the same basic properties. For example, all Primers have a sequence. If **st** is a sample type, then the following methods are available:* 
  * st.name - the name of the sample type, as in "Primer"
  * st.fieldnname - the name of the nth field, for n=1..8. Probably not useful directly. See the Sample object.
  * st.fieldntype - the type of the nth field, either "number", "string", "url", or "sample". Se the Sample object for how to use these fields.
* **Sample**: A specific (yet still abstract) sample, not to be confused with a sample type or an item. For example, a primer with a certain sequence and name will have sample type "Primer" and possibly many items in the lab for the given sample. If **s** is a sample, then the following methods are available:
  * s.id - The id of the sample.
  * s.name: The name of the sample. For example, a sample whose SampleType is "Plasmid" might be named "pLAB1".
  * s.sample_type - The sample type of the sample. 
  * s.properties - A hash of the form { key1: value1, ..., key8: value8 } where the nth key is named according to the s.sample_type.fieldnname (as a symbol, not a string).
* **Item**: A physical item in the lab. It has an object type and may correspond to a sample, see the examples below. If **i** is an item, then the following methods are available:
  * i.id - the id of the item. Every item in the lab has such an id that can by used to find information about the item (see Finding Items and Samples).
  * i.lcoation - a string describing where in the lab the item can be found.
  * i.object_type - the object type associated with the item.
  * i.sample - the corresponding sample, if any. Some items correspond to samples and some do not. For example, an item whose object type is "1 L Bottle" does not correspond to a sample. An item whose object type is "Plasmid Stock" will have a corresponding sample, whose name might be something like "pLAB1".
  * i.datum - data associated with the item. It can be an arbitrary Ruby value, but is usually a hash.
  * i.datum = x - set the value of the datum associated with the item to x. 
  * i.save - if you make changes to an item, you have to call i.save to make sure the changes are saved to the database.
  * i.reload - if the item has changed somehow in the database, this method update **i** so that it has the latest information from the database.

Finding Items and Samples
===
To find items and samples in the database, use the **find** method. This method is most easily explained via examples. 

	find(:item, id: 123)
	
This call to **find** returns a list of items whose id is 123. There should be zero or one such item. Just remember that **find** always returns a list.

	find(:item, sample: { name: "pLAB1" })
	
This call to **find** returns a list of items that correspond to the sample named "pLAB1". If that sample were a plasmid, then the items returned would be all plasmid stocks and E. coli plasmid stocks, etc. with "pLAB1" in them.

	find(:item, sample: { object_type: { name: "Enzyme Aliquot" }, sample: { name: "ecoRI" } } )
	
This call returns a list of all aliquots of ecoRI. 

	find(:sample, name: "pLAB1")
	
This call returns all samples named "pLAB1". Since names are unique, this call should return zero or one item. 

As an example of how one might use the **find** method, supose here is a protocol that tells the user to check that all the 1 kb Ladders are where they are supposed to be. 

```ruby
	class Protocol
	
	  def main
	  
	    ladders = find(:item, sample: { name: "1 kb Ladder" } )
	    
	    ladders.each do |ladder|
	    
	      data = show {
	        title "Item Number #{ladder.id}"
	        note "This item should be at location #{ladder.location}"
	        select ["Yes", "No"], var: "okay", label: "Is the item in the proper location?"
	      }
	      
	      if data[:okay] == "No"
	        show {
	          title "Yikes!"
	          warning "Do something to find item number #{ladder.id}!!!"
	        }
	      end
	    
	    end
	    
	  end
	  
	end
```
 
Taking, Releasing and Producing Items
===

To make new items you use the **produce**

Collections
===

Tasks
===

Including Modules in Other Files
===
