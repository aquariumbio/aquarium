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

Arguments
===

Returning Values
===

Items and Samples
===

Finding Items and Samples
===

Taking, Releasing and Producing Items
===

Collections
===

Tasks
===

Including Modules in Other Files
===
