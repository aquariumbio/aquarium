class ShowBlock

  def initialize
    @parts = []
    @get_counter = 0
    @select_counter = 0
  end

  def title str
    @parts.push({title: str})
  end

  def note str
    @parts.push({note: str})
  end

  def warning str
    @parts.push({warning: str})
  end

  def check str
    @parts.push({warning: str})
  end

  def get type, opts={}
  	raise "First argument to get should be either 'number' or 'text'" unless type == 'number' || type == 'text'
  	options = {
  		var: "get_#{@get_counter}",
  		label: "Enter a #{type}"
  	}
  	@get_counter += 1
    @parts.push({input: (options.merge opts).merge({type: type})})
  end

  def is_proper_array c
    if c.class == Array 
		if c.length > 0
			t = c[0].class
			return false unless t == Fixnum || t == Float || t == String
			c.each do |x|
				return false if t != x.class
			end
			return true
		else
			false
		end
    else
    	false
    end
  end

  def select choices, opts={}
  	raise "First argument to select should be an array of numbers or strings" unless is_proper_array choices
  	options = {
  		var: "select_#{@select_counter}",
  		label: "Choose"
  	}
  	@select_counter += 1
    @parts.push({select: (options.merge opts).merge({choices: choices})})
  end

  def run &block
  	instance_eval(&block)
  	@parts
  end

end

def show 
	ShowBlock.new.run(&Proc.new)
end

puts show {
	title "Hello"
	note "World"
	note "Universe"
	get "text", var: "x", label: "Enter a string", default: "Hello"
	get "number", var: "y", label: "Enter a number"
}.to_s

def input
	{ message: "wow" }
end

x = show {
  title input[:message]
  note "Thanks for using aquarium"
  warning "Careful!"
  check "Check me"
  select [ "A", "B", "C" ], var: "x", label: "Choose something", default: 1 
  get "text", var: "y", label: "Enter a string", default: "Hello World"
  get "number", var: "z", label: "Enter a number", default: 555
}

puts x.to_s

puts show {
	get "number"
	select [ 1, 2 ]
}
 