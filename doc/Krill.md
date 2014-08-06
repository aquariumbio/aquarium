Authoring Protocols for Aquarium
===

Prerequisites
---
To author a protocol for Aquarium, you should

* Have access to an Aquarium server, preferably a rehearsal server where mistakes don't matter.
* Have access to a github repository that the Aquarium server can see when you choose "Protocols > Under Version Control" from the menu.
* Understand enough about github to be able to create a new file, edit it, and save it.
* Know a bit of the Ruby programming language. Check out [the Ruby Page](https://www.ruby-lang.org/en/) for documentation.


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

The above example illustrates several important aspects of all protocols.

First, the code is all wrapped in a class called **Protocol**. Aquarium looks for this class when it starts the protocol. You must define it, otherwise you will get an error when you run the protocol.

Second, the method **main** is defined within the  **Protocol** class. This method is Aquarium's first and main entry point into your protocol.

Third, **show** is a function made available to your code by Aquarium. It takes a Ruby block (denoted by curly braces, or by **do ... end** if you wish). Within the block, there are a number of functions that are available, including the function **title**, which takes a string as an argument. The **show** function is how you communicate with the user running your protocol. It is a blocking call, meaning that your code stops running until the user clicks "Next" from within Aquarium. You might think of it as simultaneous "puts" and "gets" calls. You can have any number of calls **show** in your code and you can put fairly complex stuff into the show block.

All About Show
===

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
