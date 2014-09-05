module Krill

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
      @parts.push({check: str})
    end

    def bullet str
      @parts.push({bullet: str})
    end

    def table m
      @parts.push({table: m})
    end

    def item t
      @parts.push({take: t})
    end

    def raw p
      @parts.concat p
    end

    def separator
      @parts.push({separator: true})
    end

    def image name
      @parts.push({image: "#{Bioturk::Application.config.image_server_interface}#{name}"})
    end

    def upload opts={}
      @parts.push({upload: opts})
    end

    def transfer x, y, routing

      routing_details = routing

      routing_details.each do |r|
        m = x.matrix
        raise "m is null" unless m
        sid = m[r[:from][0]][r[:from][1]]
        raise "Tried to route from empty element #{[r[:from][0],r[:from][1]]} of collection #{x.id}" unless sid != -1
        r[:sample_name] = Sample.find(sid).name
      end

      @parts.push({transfer: { 
        from: { id: x.id, type: x.object_type.name, rows: x.dimensions[0], cols: x.dimensions[1] },
        to:   { id: y.id, type: y.object_type.name, rows: y.dimensions[0], cols: y.dimensions[1] },
        routing: routing_details 
      }})

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
    		label: "Choose",
        multiple: false
    	}
    	@select_counter += 1
      @parts.push({select: (options.merge opts).merge({choices: choices})})
    end

    def run &block
    	instance_eval(&block)
    	@parts
    end

  end

end