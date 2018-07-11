

module Krill

  # The ShowBlock class implements the methods inside show blocks, which are used to interact with the technician. When
  # a show block is encountered, it is used to construct a page of instructions for the technician. Execution is suspended
  # until the user clicks "OK" in the protocol. The show method returns a ShowResponse object that contains any information
  # entered by the user via get, select, or table inputs. 
  # 
  # The following is an example of a show block that demonstrates every method.  
  #
  # @example A show block with everything
  #   item = Item.last
  #   response = show do 
  #     title "Title describing what the technician should do in this step"
  #     note "Body text goes inside notes describing the details of this step of the protocol"
  #     warning "A warning will be displayed vibrantly"
  #     check "A checkbox will precede this text, and the user must click it to proceed"
  #     bullet "For bullet lists"
  #     table [ [ "A", "B" ], [ 1, 2 ] ]
  #     item item
  #     separator
  #     image "/path/to/s3/image.jpg"
  #     timer initial: { hours: 0, minutes: 2, seconds: 30 }
  #     upload var: "my_upload"
  #     get "text", var: "y", label: "Enter a string", default: "Hello World"
  #     get "number", var: "z", label: "Enter a number", default: 555
  #     select [ "A", "B", "C" ], var: "choice", label: "Choose something", default: 1
  #  end
  #
  # @api krill
  class ShowBlock

    # @api private
    @@get_counter = 0

    # @api private
    @@select_counter = 0

    # @api private
    @@upload_counter = 0

    def initialize(base)
      @base = base
      @parts = []
    end

    def title(str)
      @parts.push(title: str)
    end

    def note(str)
      @parts.push(note: str)
    end

    # This is deprecated
    # @api private
    def log(data)
      @parts.push(log: data)
    end

    def warning(str)
      @parts.push(warning: str)
    end

    def check(str)
      @parts.push(check: str)
    end

    def bullet(str)
      @parts.push(bullet: str)
    end

    def table(m)
      if m.class == Table
        @parts.push(table: m.all.render)
      else
        @parts.push(table: m)
      end
    end

    def item(t)
      @parts.push(take: t)
    end

    # This is deprecated
    # @api private
    def raw(p)
      @parts.concat p
    end

    def separator
      @parts.push(separator: true)
    end

    def image(name)
      @parts.push(image: "#{Bioturk::Application.config.image_server_interface}#{name}")
    end

    def timer(opts = {})
      options = {
        initial: { hours: 0, minutes: 1, seconds: 0 },
        final: { hours: 0, minutes: 0, seconds: 0 },
        direction: 'down'
      }.merge opts
      @parts.push(timer: options)
    end

    def upload(opts = {})
      options = {
        var: "upload_#{@@upload_counter}"
      }
      @@upload_counter += 1
      @parts.push(upload: options.merge(opts))
    end

    # This is deprecated
    # @api private
    def transfer(x, y, routing)

      routing_details = routing

      routing_details.each do |r|
        m = x.matrix
        raise 'm is null' unless m
        sid = m[r[:from][0]][r[:from][1]]
        raise "Tried to route from empty element #{[r[:from][0], r[:from][1]]} of collection #{x.id}" unless sid != -1
        r[:sample_name] = Sample.find(sid).name
      end

      @parts.push(transfer: {
                    from: { id: x.id, type: x.object_type.name, rows: x.dimensions[0], cols: x.dimensions[1] },
                    to:   { id: y.id, type: y.object_type.name, rows: y.dimensions[0], cols: y.dimensions[1] },
                    routing: routing_details
                  })

    end

    def get(type, opts = {})
      raise "First argument to get should be either 'number' or 'text'" unless type == 'number' || type == 'text'
      options = {
        var: "get_#{@@get_counter}",
        label: "Enter a #{type}"
      }
      @@get_counter += 1
      @parts.push(input: (options.merge opts).merge(type: type))
    end

    # @api private
    def is_proper_array(c)
      if c.class == Array
        if !c.empty?
          t = c[0].class
          return false unless t == Integer || t == Float || t == String
          c.each do |x|
            return false if t != x.class
          end
          true
        else
          true
        end
      else
        false
      end
    end

    def select(choices, opts = {})
      raise 'First argument to select should be an array of numbers or strings' unless is_proper_array choices
      options = {
        var: "select_#{@@select_counter}",
        label: 'Choose',
        multiple: false
      }
      @@select_counter += 1
      @parts.push(select: (options.merge opts).merge(choices: choices))
    end

    # @api private
    def run(&block)
      instance_eval(&block)
      @parts
    end

    # @api private
    def method_missing(m, *args, &block)

      if m == :show
        raise "Cannot call 'show' within a show block."
      else
        @base.send(m, *args, &block)
      end

    end

  end

end
