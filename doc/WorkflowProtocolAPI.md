# Workflow Protocols

## Getting an Operation Object

The input to a protocol in the workflow framework is a JSONable object containing information about the inputs, outputs, parameters, data, and exceptions in the workflow. To manage this information, and all the information associated with the protocol, an object of type *Op* is created at the beginning of every protocol as follows:

    o = op input
    
The object *o* is then used throughout the protocol. The reason the letter "o" is used here is for the sake of brevity. The operation *o* is used mainly through method chaining. For example, you might write

    o.input.all.take
    
which works as follows. The *input* method tells *o* that later method calls should refer to the input to the operation. It returns an object of type *Op* as well. The *all* method then selects all inputs (as opposed to one particular input). It also returns an object of type *Op*. Finally, the *take* method tells interacts with the user, telling her/him where to find all the inventory specified in the inputs. These methods are explained in detail below.

## Selecting Parts of the Operation

An operation has inputs, outputs, parameters, and data. To tell the operation which parts of it subsequent methods will refer to, use one of the following

    o.input
    o.output
    o.parameter
    o.data
    
Whatever selection shows up last takes precedence. So 

    o.input.output
    
Selects the output, ignoring what the previous selection of input.

Each input, output, parameter, or data has a name, which shows up in the workflow diagram. To select a particular named part, use the name of the part. For example, if an operation has an input named *fwd*, you can select it as in

	o.input.fwd
	
If the operation has another input named *rev*, you can select both *fwd* and *rev* as in

    o.input.fwd.rev
    
Finally, you can select all input or all output parts as in

    o.input.all
    
Or

    o.output.all
    
## Options

Options set particular flags for latter inactions with an *Op*. Presently, the following options for the *take*, *produyce*, and *release* methods, discussed below, are available.

	o.query(bool)		# => whether to query the user about which item to take
	o.silent(bool)      # => whether to take, produce or release silently (without user interaction)
	o.method(string)    # => what method to use with take and release (e.g. "boxes")
	
For example, to silently release the items associated with the output named #fragment# you would do

	o.output.fragment.silent(true).release
	
## Collections

If an input or output is specifed as a collection (because its Container has a collection handler), then it will be instantiated with one or more actual collections. Collections are typically also specified as being shared by some number of threads. For example, a gel might have twelve lanes. One of the lanes is used for a DNA ladder, so that eleven lanes are left for samples. Thus, in the *gel* input to a "Run Gel" protocol would be shared with eleven threads. If the workflow were run with 50 samples, then ceiling(50/11) = 5 gels would be needed. A class called *CollectionArray* is used to manage such an array of collections. To get the collection array for an input or output, do something like the following.

	c = o.input.gel.collections
	
which will return the set of collections being input to the operation.
	
	
	
	