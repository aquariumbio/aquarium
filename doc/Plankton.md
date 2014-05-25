# The Plankton Protocol Language

### by Eric Klavins
### November, 2013

## Comments

A comment starts with the **#** symbol and ends with a newline, as in 

	# This line is a comment

## Expressions

Expressions in Plankton evaluate to Booleans, numbers, strings, arrays, and hashes. Boolean values are denoted **true** or **false**. Numbers are standard. Strings are double quoted, as in "Hello" and may span multiple lines. Arrays are delimited by square brackets and elements are separated by commas as in, for example:

	[ 1, 2, 3 ]
	
Array values are accessed as in A[0], A[1], etc. Hashes are delimited by curly braces, keys are separated from values by colons, and key/value pairs are separeted by commas, as in

	{ x: 1, y: "hello", z: [ 1, 2 ] }
	
The keys in hashes are called symbols and are values in and of themselves. The keys in the above hash are :x, :y, and :z. If h is the above hash, then the value for :x in h is accessed via h[:x].

All the standard boolean operations are available: &&, ||, and !. All the standard numerical operators are available: +, -, *, /, and \*\* with \*\* representing exponentiation. Modulo is not done with n%k but with mod(n,k).

Strings can be concatenated using the + operator. Also, a string such as

	"The value of x is %{x}"
	
will have %{x} replaced by the value of the variable x at the time the string is processed by the interpreter. Note that only variable identifiers can go in %{}, not arbitrary expressions. To use a percent sign in a string, use two percents in a row as in

	"80%% of all statistics are made up."
	
An expressions can appear as the right hand side of an assignment, as an argument to a function, or as a parameter. An expression may also appear on a line by itself, in which case it is evaluated but not assigned to any variable (useful for functions with sides effects).
	
## Predefined Functions

Plankton (and Oyster) provide a number of predefined functions, which are described [here](Predefined.md).

## Variables and Assignments

Identifiers (variable names) may begin with a letter or underscore and be followed by any number of letters, digits, or underscores. To assign a variable to a value use = as in 

	x = 1
	y = x + 1
	z = { a: x, b: y }
	z[:a] = 2
	A = [1, 2, 3]
	A[0] = 4
	
and so on. Variables are global when initialized outside of an if, while, or foreach block. In particular, variables inside functions are considered global unless forced to be local with the **local** keyword. For example, this code

	y = 0

	function f(x)
		y = x+1
		return y
	end
	  
	f(1)
	z = y
  
results in z having the value 2, while this code

	y = 0

	function f(x)
		local y = x+1
		return y
	end
  
	f(1)
	z = y

results in z having the value 0.

## Blocks

Most instructions in Plankton have the form of a block, as in

	instruction
		line 1
		line 2
		…
	end

Some blocks requre that line 1 has a special structure. For example, **modify** and **produce**. For others, such as **step**, the order of the lines does not matter.

## Argument

Each argument to a protocol has an associated identifier, a type, and an optional string to describe what the argument is for. The type of an argument can be either **number**, **string**, **sample**, **object**, or **generic** and is *only used to tell the interpreter what kind of input field to use in the user interface* when starting the protocol. Arguments are specified in blocks. There can be several such blocks, or none, and they can appear anywhere in the protocol. Arguments do not change the flow of the program and are only used when starting the protocol, or when including it from another protocol. An example argument block is

	argument
		w: number, "An important number"
		x: string, "Your name"
		y: sample 
		z: object
		j: generic
	end
		
where the first two arguments are associated with helpful string decriptions, and the second two happen not to be. The sample argument expects the id (an integer) of a sample item in Aquarium. The object argument expects the string name for the object. The generic argument expects a json parsable input and presents the user with a textbox to edit it. The json is converted into a datatype readable by Plankton (i.e. A hash with symbol keys, an array, a number or a string, or some combination thereof.)

When a user starts a protocol directly via Aquarium, she/he must fill in the arguments. Number and strings are entered via the keyboard. Object types are selected from a dropdown menu of all object types. Samples are selected from a dropdown menu of the samples in the user's cart. If an argument has type sample, then following syntax will limit the options in the dropdown menu. For example,

	argument
		one: sample("Plasmid")
		two: sample("Plasmid")
		id: sample("E coli strain")
	end
	
will restrict the dropdowns for the first two arguments to samples of type "Plasmid" whereas the third argument will restrict the dropdowns to samples or type "E coli strain". All characters before the last underscore in the argument name are used to construct the sample type name.

Arguments can also be arrays of numbers, strings, or samples These are specified as

	argument
		x: number array, "An array of numbers"
		y: string array, "An array of strings"
		s: sample array, "An array of samples"
	end
	
the variables x, y and s in the above will evaluate to arrays. The length of the array is not specified, but will be filled in by the user via the interface. 


## Step

The step instruction is the primary means of displaying information for and getting information from the user. A generic step instruction has the form

	step
		description: "A string"
		note: "Another string"
		bullet: "Any number of bulleted items. No sublists though."
		check: "A check item needs to be checked by the user before they can proceed."
		image: "Yet another string"
		warning: "Look out!"
		getdata
			x: number, "A useful message"
			y: string, "Another useful message"
			z: string, "Make a choice", [ "A", "B", "C" ]
 		end
 		timer: { hours: 0, minutes: 3, seconds: 30 }
 		table: [ [ "A", "B"], [ 1, 2 ], [3, 4 ] ]
 	end
 
All of the fields are optional, although there should be at least one. The **description** field is used to display a short message, kind of like a title, at the top of the page. The **note** field displays in depth instructions, in a smaller font, beneath the description. Any number of **bullet** fields, which are displayed like notes except with a bullet before them, can be used. The **check** field requires that the user click a checkbox before proceeding. The **warning** field displays a short message in a highlighted box. The **image** field looks for an image in bioturk's image server (e.g. Angler) and displays it with the step. The **timer** field will display a countdown timer that is initialized to the hours, minutes and seconds specified. When the timer reaches zero, it will start blinking and beeping to get the user's attention. The **table** field will show a table with the specified rows and columns. Strings in the stable will be displayed differently than numbers, for use in column or row headings.

The **getdata** sub-block is used to request information from the user. Each entry in the block is of the form 

	indentifer: type, "Optional String"
	
An entry may also be followed by an optional array of choices which results in a select box being shown to the user, as in the entry for z in the example above. In this case, the optional string must be present.
 	
Steps may have foreach statements in them as in, for example,


	L = [ "a", "b" ]
    M = [ 1, 2, 3 ]
	step
		foreach i in L
			foreach j in M
				check: "Do something to the tube labeled %{i}-%{j}"
			end
		end
	end
	
Note that the only things allowed in the body of a foreach statement *that appears inside a step* are step fields such as those in the above steps. Assignments and other instructions are not allowed. 
	
**WARNING:** Using functions inside foreach statements in steps will not work. 

## Take

The **take** block is used to take items from the inventory for use in a protocol, somewhat like an ingredient in cooking. Each take block will be rendered for the technican as a list, which each element in the list corresponding to a particular item. In the case that multiple items are available, the user will be presented with a dropdown menu to choose the particular item she/he wil retrieve. 

Items to take can be specified having a certain type along with the quantity needed as in

	take
		2 "1000 mL Bottle"
	end

which will request that the user take two bottles. If it is required that a variable keep track of the items taken, then use

	take
		x = 2 "1000 mL Bottle"
	end
	
which will put the specific items take into an array of hashes, one hash for each item. 

The hash for an item has the form

	{ id: 123, name: "1000 mL Bottle", data: { field1: value1, field2: value2, ... } }
	
So the above take will assign the variable x to something like

	[
		{ id: 123, name: "1000 mL Bottle", data: {} }, 
		{ id: 124, name: "1000 mL Bottle", data: {} }
	]

assuming bottles have empty data fields. Individual items in x are refered to as x[0] and x[1]. The elements of the items can be obtained as well. For example, x[0][:id] refers to the inventory id number of the item x[0].

Specific items can be taken be specifying the item id, as in 

	take
		item 7278
	end
	
or

	take
		y = item 438
	end
	
which both tell the user where to find the item in question (if it is available). The latter instruction puts a hash for the item in an array and associated it with the variable y.

Multiple itmes can be taken in each block, although for style reasons 4-5 items is the maximum that the used should have to see in a single take. As an example,

	take
		x = 2 "1000 mL Bottle"
		item 7278
		y = item 438
	end
	
requires the user to take 2 bottles, and to take items 7278 and 438.

A note to the user can be added to a take instruction using an option **note:** field as in the following.

	take
		x = 1 "1000 mL Bottle"
		note: "Take the cleanest bottle you can find."
	end
	
The note will be display just under the title of the take page.

The **take** instruction also works with arrays. To take an array of samples, do

    take
        x = item [ 123, 234, 345 ]
    end
    
To take an array of objects, you can do

	ob = [ "Bottle", "Spatula" ]
	q = [ 2,1 ]
	take
	    y = q ob
	end
	
which will take 2 bottles and 1 spatula. Note that you could also do

    take
      y = ( [ 2, 1 ] ) ( [ "Bottle", "Spatula" ])
    end
   
Note the parentheses, which in this case are required to prevent the parser from getting confused.

## Produce

The **produce** instruction is used to create a new item to be stored by the user. The user will be presented with a page that asks her/him where to store the item. The most basic form of produce is

	produce
		1 "Thing"
	end
	
where "Thing" is the name of an object type. If a variable is required to store the resulting item, then use

	produce
		q = 1 "Thing"
	end
	
If the item being produce contains a sample, then sample information needs to be associated with it. The following for example produces an object type "Thing" with a sample "Goo" in it.

	produce
		q = 1 "Thing" of "Goo"
	end

As long as there is a sample named "Goo" with an object type "Thing" that can contain it listed in the Aquarium database, the above will work.

Another option is to use an item that has already been taken and that has a sample in it. For instance, suppose that y was returned in the last example take instruction above. Then y is an array containing a single hash that corresponds to item 438. To produce a new item with the same sample type, use **from** as in

	produce
		q = 1 "Thing" from y[0]
	end
	
Note that in this case, "Thing" has to be an object type with handler sample_container and it has to be associated with the sample type that y[0] is associated with.

To associate data with a produced sample, use the **data** sub-block, which can contain any number of field/value pairs separated by colons. For example,

	produce
		q = 1 "Thing" from y[0]
		data
			concentration: 123
		end
	end
	
The values in a data block can be arbitrary expressions. To retrieve data stored with an item, you can access its data field as in

	c = q[0][:data][:concentration]

which works for items obtained via **take** instructions as well.

If any items consumed when the produced item is made can be released silently with the release sub-instruction, as in 

	produce
		1 "Widget"
		release z
	end
	
where z must be an array of item hashes that were returned by a take or produce command. 

Using the optional **location** field, a location can be specified to the user in an input box so they can change it if necessary. 

	produce
		1 "Widget"
		location: "X1.999"
	end

If no location is specified for the new item, then the user will be shown a default location for the item. 

Produce instructions usually show the user a page describing where to put the item and how to label it. To supress this behavior, use the keyword 'silently' as in

	produce silently
		1 "Widget"
		location: "X1.999"
	end

In this case, the user should be instructed what to do with the produce item in some other way.

## Release

To release an array **x** of items, for example one associated with a take instruction, use the release instruction as in

	release x
	
This instruction will display a checklist to the user that user should use to make sure she/he has returned all the items. The item's object type information is used to determine whether the item should be returned, disposed, or if the user should be queried about what to do.

## Modify

Certain fields of items taken from the inventory can be modified in Plankton. 
The **location** field can be set to a string.
The **inuse** and **quantity** fields can be set or incremeneted (with **iinuse**, **iquantity**) or
decremented (with **dinuse**, **dquantity**).
These capabilities should be used sparingly. 
The safer way to modify these fields is by appropriately taking and releasing items. 
However, there may be situations where modifiy is required to make a protocol flow. 
An example modify instruction, assuming x contains an array of items from a take instruction, is

	modify 
		x[0]
		location: "A1.234"
		inuse: 0
	end
	
Neither the **location** or the **inuse** is required. 

## Log

The log instruction is a block containing field / expression pairs separated by colons. When processed, the log block will write each pair to the log. As an example, 

	log 
		a: x+1
		b: -9
		c: { a: "stuff", b: [ 1, 2 ], c: { d: "asd" } }
	end
  
will create three separate log items with entry types **a**, **b**, and **c** respectively.

## Http

To send a GET request to another computer via http, use and http block, as in, for example:

	http
		host: "http://www.google.com"
		query
			q: "life"
		end
		status: s
		body: b
	end
	
The query sub-block can contain any number of field / value pairs. They are added to the url as in "http://www.google.com?q=life". In this request, the resulting status of the request (e.g. 200 for a successful query) is accessible after the block via the variable **s**, and the body of the returned resource is accessible in **b**.

## Information

You can associate descriptive information with a protocol using the information instruction as in

	information "This protocol is used to make widgets out of gizmos."

## If, elsif, else

Conditional execution is accomplished with **if**, **elsif**, and **else** blocks. After an **if** statement, any number of **elsif** blocks (including zero) and either zero or one **else** block. The syntax is straightforward, as in 

	if x == 0
		y = "zero"
	elsif x < 0
		y = "negative"
	else
		y = "positive"
	end
	
Any number of instructions of any type may appear within each block. If statements can also be nested. Each block of an if statement starts a new local scope. So variables defined within an if statement are local to the statement and will not overwrite variables of the same name outside of the if statement.

## While

A while block executes its statements as long as its condition is true. An example is

	x = 0
	while x < 10
		step
			description: "x is %{x}"
		end
		x = x + 1
	end
	
which displays 10 steps to the user. As with if statements, each the body of a while statement starts a new local scope.

## Foreach

An array can be iterated through using the foreach statement as in

	A = [ 1, 2, 3 ]
	foreach a in A
	  step
	    description: "In the loop, a = %{a}"
	  end
	end
	
As with if and while statements, each the body of a foreach statement starts a new local scope. In particular, the iterator will be a variable local to the scope (e.g. in the example above, the iterator a is local to the foreach statement).

## Stopping

The stop instruction, which is simply written

	stop
	
halts the protocol. If you use it, you might want to have a step instruction before the stop to tell the user why you are stopping, and you also might want a log instruction before the stop to log whatever made the protocol arrive at a stop.

## User Defined Functions

Users can define their own functions using the **function**, **local**, and **return** keywords. The general form of a function is

	function f(x,y,...,z)
	   # body here
	   return expr
	end
	
where any list of statements can replace appear in the body. The optional return statement can appear anywhere in the body and there can be any number of returns -- although only the first one encountered during execution will be evaluated.

An example showing a simple function definition is as follows.

	function cleanup(msg)
	  step
	    description: "Clean up your workstation"
	    note: "%{msg}"
	  end
	end

This function can be called as in

	cleanup("Leave it cleaner than you found it")
	
at any point after the definition. Such commonly used functions are intended to be put in library files and included (or, equivalently, required) and then called as needed.

Functions can return values as well. For example, to produce a number of samples silently and get back a list of the resulting item ids, you might do the following.

	function produce_minipreps(strains)

	  local result = []
	  local p

	  foreach s in strains

	    plasmid = info(s)[:field2]

	    produce silently 
	      p = 1 "Plasmid Stock" of plasmid
	    end

	    result = append(result,p[:id])

	  end

	  return result

	end
	
Later, you can call this function as in

	argument
	  ids: sample("Transformed E coli Strain") array, "Stocks"
	end

	take
	  strains = item ids
	end

	result = produce_minipreps(strains)
	
in which case **result** will contain a list of the items produced, which you could use to inform the user about what just happened.

Functions can be recursive, by the way. For example, you can define

	function f(n)
	  if n > 0
	    return n*f(n-1)
	  else
	    return 1
	  end
	end
	
on the off chance that such a function is needed in a wetlab. Note that the return statements in this definition are not at the end of the function. The meaning of return is to stop the execution of the function immediately and return the value. Multiple returns are permitted, with the first one encountered being the return taken. If no return is specified, the function returns the value **false** by default.

## Include

Other Plankton files on github can be included by a given Plankton file. If an include block is encountered during runtime

* First, a new scope is pushed onto the stack, to prevent variable name collisions.
* Second, arguments for the included file are assigned.
* Third, the control is moved to instructions associated with the included.
* Fourth, once the control leaves the included file, return values are associated with variables in the calling file's scope. 
* Fifth, the included file's scope is popped.

An example include block is as follows.

	include "path/to/my_favorite_protocol.pl"
	  x : 1
	  y : "whatever"
	  z = u
	end
	
Each line of the include block is either an argument assignment or a return variable assignment. In the above example, the sub-protocol is called with arguments x set to 1 and y set to "whatever". When the included protocol is complete, the variable z in the calling protocol's scope is set to the variable u in the called protocol's scope.

The **require** keyword is a convenience keyworkd similar to **include** except that it has no block. So

	require "whatever.pl"
	
is equivalent to

	include "whatever.pl"
	end

## Input

Note that **include** and **require** are processed before the program is run to create a final low-level list of instructions for the interpeter. To take in data from other files in the github repository as the Plankton program is running, use input, which reads in JSON expressions and assigns them to the variable provided. For example, if parameters.json contains

	{
	 "primers" : [ 7671, 7674, 7691, 7692 ],
	 "plasmids" : [ 938, 927 ]
	}

then doing

	input
	  p = "plankton/sandbox/parameters.json"
	end

would assign p to the hash specified in the file. The fields could be accessed with p[:primers] or p[:plasmids] in this case.
