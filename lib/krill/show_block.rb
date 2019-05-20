module Krill

  # The ShowBlock class implements the methods inside show blocks, which are used to interact with the technician. When
  # a show block is encountered, it is used to construct a page of instructions for the technician. Execution is suspended
  # until the user clicks "OK" in the protocol. The show method returns a ShowResponse object that contains any information
  # entered by the user via get, select, or table inputs. 
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
  #     image "path/to/s3/image.jpg"
  #     timer initial: { hours: 0, minutes: 2, seconds: 30 }
  #     upload var: "my_upload"
  #     get "text", var: "y", label: "Enter a string", default: "Hello World"
  #     get "number", var: "z", label: "Enter a number", default: 555
  #     select [ "A", "B", "C" ], var: "choice", label: "Choose something", default: 1
  #   end
  #
  # @api krill
  class ShowBlock

    # @api private
    @@get_counter = 0

    # @api private
    @@select_counter = 0

    # @api private
    @@upload_counter = 0

    # @api private
    def initialize(base)
      @base = base
      @parts = []
    end

    # Put the string s at the top of the page. Usually only called once in a given call to show.
    # @param str [String]
    # @return [void]
    def title(str)
      @parts.push(title: str)
    end

    # Put the string s in a smaller font on the page. Often called several times.
    # @param str [String]
    # @return [void]
    def note(str)
      @parts.push(note: str)
    end

    # This is deprecated
    # @api private
    # @return [void]
    def log(data)
      @parts.push(log: data)
    end

    # Put the string s in bold, eye catching font on the page in hopes that the user might notice
    # it and heed your advice.
    # @param str [String]
    # @return [void]
    def warning(str)
      @parts.push(warning: str)
    end

    # Put the string s on the page, with a clickable checkbox in front of it. The user will need
    # to click all checkboxes on a given page before the "OK" button is enabled. 
    # @param str [String]
    # @return [void]
    def check(str)
      @parts.push(check: str)
    end

    # Put the string s on the page, with a bullet in front of it, as in a bullet list.
    # @param str [String]
    # @return [void]
    def bullet(str)
      @parts.push(bullet: str)
    end

    # Display a table represented by the matrix t. The method takes a 2x2 list of either numbers,
    # strings, or hashes. In the case of hashes, the following fields can be present.
    # 
    # content: A number or string
    # check: Whether the entry is checkable, true or false
    # style: A hash containing css
    #
    #
    # See the [Operations](md-viewer?doc=Operations) documentation for more information about
    # how to construct tables automatically based on the inputs and outputs to a protocol's
    # operation.    
    # @param m [List]
    # @example
    #   show {
    #     table [ [ "A", "B" ], [ 1, 2 ] ]
    #   }    
    # @example
    #   m = [
    #     [ "A", "Very", "Nice", { content: "Table", style: { color: "#f00" } } ],
    #     [ { content: 1, check: true }, 2, 3, 4 ]
    #   ]
    #   show {
    #     title "A Table"
    #     table m
    #   }   
    # @return [void] 
    def table(m)
      if m.class == Table
        @parts.push(table: m.all.render)
      else
        @parts.push(table: m)
      end
    end

    # Display information about the item i -- its id, its location, its object type, and its sample type 
    # (if any) -- so that the user can find it. 
    # @param i [Item]
    # @return [void]
    def item(i)
      @parts.push(take: i)
    end

    # This is deprecated
    # @api private
    def raw(p)
      @parts.concat p
    end

    # Display a break between other shown elements, such as between two notes.
    #
    # @return [void]
    def separator
      @parts.push(separator: true)
    end

    # Display the image pointed to by **name** on the page. The **name** argument will be prepended
    # by the URL to the S3 url defined by Bioturk::Application.config.image_server_interface in
    # config/initializers/aquarium.rb
    #
    # @example
    #   image "containers/bottle_1_liter.jpg"
    # @param name [String]
    def image(name)
      @parts.push(image: "#{Bioturk::Application.config.image_server_interface}#{name}")
    end

    # Show a rudimentary timer. By default, the timer starts at one minute and counts down. 
    # It starts beeping when it gets to zero, and keeps beeping until the user clicks "OK". 
    # You can specify the starting number of hours, minutes, and seconds, with for example
    # The initial option can be used to set the initial time on the timer and has field
    # hours, minutes, and seconds, all numerical.
    #
    # @example
    #   timer initial: { hours: 0, minutes: 20, seconds: 30}
    # @option opts [Hash] :initial
    # @return [void]
    def timer(opts = {})
      options = {
        initial: { hours: 0, minutes: 1, seconds: 0 },
        final: { hours: 0, minutes: 0, seconds: 0 },
        direction: 'down'
      }.merge opts
      @parts.push(timer: options)
    end

    # Upload a file. The optional name specified by the :var option can be used to retrieve the upload.
    #
    # @example
    #   response = show do
    #     upload var: "my var"
    #   end
    # See the [ShowResponse] documentation for how to manipulate uploads.
    # @option opts [String] :var
    # @return [void]
    def upload(opts = {})
      options = {
        var: "upload_#{@@upload_counter}"
      }
      @@upload_counter += 1
      @parts.push(upload: options.merge(opts))
    end

    # This is deprecated
    # @api private
    # @return [void]
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
                    to: { id: y.id, type: y.object_type.name, rows: y.dimensions[0], cols: y.dimensions[1] },
                    routing: routing_details
                  })

    end

    # Display an input box to the user to obtain data of some kind. If no options are supplied, 
    # then the data is stored in a ShowResponse object returned by the **show** function with a 
    # key called something like get_12 or get_13 (for get number 12 or get number 13). The name 
    # of the variable name can be specified via the **var** option. A label for the input box can 
    # also be specified.
    #
    # @param type [String] Either "text" or "number"
    # @option opts [String] :var The name of the resulting value in the ShowResponse object
    # @option opts [String] :label The label shown next to the input box
    # @option opts [String] :default The default value if the type is text
    # @option opts [Float] :default The default value if the type is number
    # @return [void]
    # @example
    #   data = show {
    #     title "An input example"
    #     get "text", var: "y", label: "Enter a string", default: "Hello World"
    #     get "number", var: "z", label: "Enter a number", default: 555
    #   }
    #
    #   y = data[:y]
    #   z = data[:z]
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

    # Display a selection of choices for the user. The options are the same as for **get**. For example,
    #
    # param choices [List] A list of choices, either all strings or all numbers
    # @option opts [String] :var The name of the resulting value in the ShowResponse object
    # @option opts [String] :label The label shown next to the input box
    # @option opts [String] :default The default value if the type is text
    # @option opts [Float] :default The default value if the type is number
    # @return [void]
    # @example
    #   data = show {
    #     title "A Select Example"
    #     select [ "A", "B", "C" ], var: "choice", label: "Choose something", default: 1
    #   }
    #
    #   choice = data[:choice]    
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
