# The Oyster Metacol Language

### by Eric Klavins
### November, 2013

## Comments

A comment starts with the **#** symbol and ends with a newline, as in [Plankton](https://github.com/klavinslab/specifications/blob/master/Languages/Plankton.md).

## Expressions

Expressions in Plankton evaluate to Booleans, numbers, strings, arrays, and hashes, as in [Plankton](https://github.com/klavinslab/specifications/blob/master/Languages/Plankton.md).

## Variables and Assignments

As in [Plankton](https://github.com/klavinslab/specifications/blob/master/Languages/Plankton.md), identifiers (variable names) may begin with a letter or underscore and be followed by any number of letters, digits, or underscores. To assign a variable to a value use = at any point outside of a place, transition or wire (see below). Assignments can also be made in the **do** portion of a transition. 

## Arguments

Arguments have the same syntax, types, and naming conventions as does [Plankton](https://github.com/klavinslab/specifications/blob/master/Languages/Plankton.md). 

## Relationship to Petri Nets

Oyster files describe Petri Nets with a few special restrictions and additions. Before you continue to read this document, it is recommended that you read the [Wikipedia page on Petri Nets](http://en.wikipedia.org/wiki/Petri_net). In Oyster, places are used to represent sets of jobs associated with a particular protocol. Places may also be empty, in which case they are used to give structure to the network. In Oyster, transitions are also associated with expressions that further restrict when they fire. Transitions also can have sides effects such as updating variable assignments. Wires in Oyster have nothing to do with standard Petri Nets.

## Places

Places are declared with the **place** keyword which defines a new place, associate a variable with the place for later reference. In the body of the place declaration you can associate a protocol, its arguments, group, timing information, and whether the place is initially marked upon start up of the metacol.

### Fields

Specifically, the fields of a place declaration are as follows:

* **protocol**: A string refering to a protocol by its path on github.
* **argument** … **end**: A list of argument names and values to be sent to the protocol, using the names that the protocol defines in its argument block. Not all arguments need be defined, although those not specified here must be associated with wires later (see below).
* **group**: The name of a group or user in Aquarium.
* **marked**: Either true or false. If not included, then false by default.
* **start**: The desired time after which the protocol may be started. See timing below.
* **window**: The amount of time after the desired start time that the must be started before becoming overdue. See timing below.

### Timing

Oyster provides several functions for defining the start time and window length. All of these functions are evaluated every time a place is started or updated when a transition fires. So **now()** for example refers to the current time when the protocol associated with a place is subbmitted to the Aquarium job queue. 

* **now()** The current time. Used for start times.
* **today_at(h,m)** The time h hours and m minutes after midnight of the current day. Used for start times.
* **tomorrow()** Twenty four hours after the current time. Used for start times.
* **tomorrow_at(h,m)** The time h hours and m minutes after midnight of the next day. Used for start times.
* **minutes(m)** The time m minutes from now for start times, or a duration of m minutes for window lengths.
* **hours(h)** The time h hours from now for start times, or a duration of h hours for window lengths.
* **days(d)** The time d days from now for start times, or a duration of d days for window lengths.

### Example

The following example, which will continue throughout this document, declares two places called p1 and p2. The protocols one.pl and two.pl are simple protocols that can be found in protocols/plankton/. The line "num = 0" is used later in the example. 

	place p1
		protocol: "plankton/one.pl"
		group: "admin"
		marked: true
		start: now()
		window: minutes(30)
	end

	num = 0

	place p2
		protocol: "plankton/two.pl"
		argument
			y: num
		end
		group: "klavins"
		start: now()
		window: hours(8)
	end


## Transitions

Transitions are declared by describing their presets, postsets, a Boolean condition, and optional additional variable assignments. The general form of a transition declaration is

	transition [ place1, place2, … ] => [ place3, place4, … ] when condition
		do
			var = value
			…
		end
	end
	
The places listed in the preset and postset can be any subsets of the places declared in the preceding oyster code. The condition is any Boolean expression and may also use special functions that refer to the statuses of the places in the preset. These functions are

### Process Control

* **completed(i)** This function returns true when and only when the last job associated with the place in the ith position in the preset list has successfully completed. 
* **error(i)** This function returns true when and only when the last job associated with the place in the ith position in the preset list has stopped due to an error, abort, or cancel action.
* **return_value(i,str)** This function returns the value for the the key identified by **str** returned of the most recent job for place i. It returns false if there is no such job, and nil if there is no such key.
* **hours_elapsed(i,h)** Returns true if place i was started more than h hours ago.
* **minutes_elapsed(i,m)** Returns true if place i was started more than m minutes ago.

The following is an example where a place is used only for waiting a specific amount of time before the associated transition can fire. Note the place does not have an associated protocol (although it could if so desired).

	place wait
		marked: true
	end

	place one
		protocol: "something_worth_waiting_for.pl"
		group: "klavins"
		marked: false
		start: now()
		window: minutes(30)
	end

	transition [ wait ] => [ one ] when hours_elapsed(0,12) end
	transition [ one ] => [] when completed(0) end

### Inventory Control

* **quantity(objecttype)** Returns the number number of items in the inventory with this object type if a string is passed. If a hash of the form { object: string, sample: string } is passed, then quantity returns the number of its with both the object and sample type (e.g. the number of aliquots (the object type) of a given primer (the sample type)).
* **min_quantity(objecttype)** Returns the minimum allowable quantity of the object type.
* **max_quantity(objecttype)** Returns the maximum desired quantity of the object type.

The **do** block of the transition declaration is optional. If present, then assignments in the block are evaluated in order when the transition fires.

### Example (continued)

The following code declares transitions for the places declared above.

	transition [ p1 ] => [ p2 ] when !error(0) && completed(0) && num<nmax
		do
			num = num + 1
		end
	end

	transition [ p2 ] => [ p1 ] when !error(0) && completed(0) end
	transition [ p1 ] => [] when error(0) end
	transition [ p2 ] => [] when error(0) || num > 3 end

## Wires

Often, the outputs of a protocol need to be sent to the input arguments of another protocol. To do this, you must first make sure that your protocol logs a hash with entry type return (see [Plankton](https://github.com/klavinslab/specifications/blob/master/Languages/Plankton.md) for details on logging values). For example, at the end of plankton/one.pl which is associated with the first place in our example, we return a value entered by the used as in

	step
		description: "What is your favorite number?"
		getdata
			n: number, "The number"
		end
	end

	log 
		return: { n: n }
	end

The keys in the return hash can be wired to specific arguments of protocols in other places. The general syntax for a wire declaration is

	wire ( place1, variable_name1 ) => ( place2, variable_name2 )

Where place1 and place2 are previously declared place identifiers and variable_name1 and variable_name_2 are **strings** describing which key in the source place and which argument in the destination place to use. For example, to wire the key **n** to in place p1 to the argument **x** in place p2 in our example we write:

	wire (p1,"n") => (p2,"x") 

## Semantics

When a metacol written in Oyster is started in Aquarium, several actions are taken initially, and then periodically after that.

### Starting

* The metacol is given a metacol process id number and added to a list of all running metacols.
* For each place that is initially marked, a job is submitted for its associated protocol. The job will be listed in the "Pending Jobs" of any user in the associated group for the place. Its start time and window determine if it is listed as pending, overdue, or future. The job is associated with the metacol process id.

### Updates

Updates to metacols occur every second. 

* The conditions for any transitions whose presets are all marked are evaluated. All such transitions are considered as firing. Note that the list of firing transitions is computed before any transition is fired.
* For each firing transitions, in order, the markings in its preset places are decrememented, the markings in its postset places are incremeneted, and the jobs for protocols associated with the places in the postset are submitted according to the timing, group, and argument information in the place.

### Done

If a metacol has no marked places or if it encounters a runtime error, it stops. 

### Limits

Because it is easy to accidentally write an out of control metacol that spawns an infinite number of jobs, the number of active or pending jobs that can be associated with a metacol cannot exceed a maximum number, currently set to 11 (because our metacols go up to 11).  

### Status

The status of a metacol, a list of all jobs associated with it (active, completed, canceled, aborted, or crashed) can be viewed by clicking on the metacol process id in Aquarium. Error messages and limitation messages can also be viewed on that page.

### Preset variables

The login name of Aquarium user for which the metacol was started is available in the variable **aquarium_user**. 
