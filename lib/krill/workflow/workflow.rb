module Krill

  # An operation, packing together all the input, output, parameters,
  # data, and exceptions in an operation specification and providing
  # a variety of convience routines. 
  #
  # @example To get an operation object named 'o', start main with the following.
  #   o = op input
  class Op

    # @private
    def initialize spec, protocol

      @protocol = protocol
      @spec = spec
      @parts = []

      # define method chainers for i/o
      (input_names+output_names+data_names).each do |name|
        self.class.send(:define_method,name) do
          @parts.push name
          self
        end
      end

      # define method chainer for data setting
      data_names.each do |name|
        self.class.send(:define_method,"#{name}=") do |v|
          set(name,v)
          self
        end
      end      

      # define getters for parameters
      parameter_names.each do |name|
        self.class.send(:define_method,name) do
          @type = :parameters
          @parts = [ name ]
          keyval = get
          keyval[0][:instantiation].collect { |v| v[:value] }
        end
      end

      # set up defaults
      query true
      silent false
      method :boxes

    end

    # @!group Getters

    # The name of the operation
    # @return [String]
    def name
      @spec[:name]
    end

    # An array of all the input names in the operation.
    # @return [Array]
    def input_names;     @spec[:inputs].collect { |i| i[:name] };     end

    # An array of all the output names in the operation.
    # @return [Array]
    def output_names;    @spec[:outputs].collect { |i| i[:name] };    end

    # An array of all the parameter names in the operation.
    # @return [Array]   
    def parameter_names; @spec[:parameters].collect { |i| i[:name] }; end

    # An array of all the data names in the operation.
    # @return [Array]   
    def data_names;      @spec[:data].collect { |i| i[:name] };       end

    # An array of all the input, output, parameter, and data names in the operation.
    # @return [Array]
    def part_names
      input_names + output_names + parameter_names + data_names
    end

    # Returns the an array of {ISpec}s for the current selection.
    # @return [Array]
    def get
      raise "no type specified." unless @type
      type = @spec[@type]
      raise "operation's #{@type} not found." unless type
      @parts.collect do |part|
        type.find { |i| i[:name] == part }
      end
    end

    # @private
    def objects type, field
      temp = (get.collect { |part|
        part[:instantiation].collect { |i| i[field] }
      }).flatten
      ids = temp.collect { |t| 
        extract_id t
      }
      rows = type.where(id: ids)
      ids.collect { |i|
        if i
          rows.find { |r| r.id == i }
        else
          nil
        end
      }
    end

    # Returns an array of sample ids for the current selection.
    # @return [Array]
    def samples 
      self.objects Sample, :sample
    end

    # @private
    def options
      { type: @type, parts: @parts, query: @queryQ, silent: @silentQ, method: @use_method, index: @index }
    end  

    # @private
    def get_ispec_io
      unless @type == :inputs || @type == :outputs
        raise "No i/o specified. Call .input or .output first." 
      end
      get
    end

    # Returns the operation specification, for use as the return value of a protocol.
    # @example Use this code at the end of a protocol.
    #   return o.result
    # @return [Hash]
    def result
      @spec
    end

    # @private
    def extract_id descriptor
      if descriptor.class == String
        descriptor.split(':')[0].to_i
      else
        descriptor
      end
    end

    # Returns an array {ISpec}s corresponding to the current selection.
    # @return [Array]
    def specs
      (get.collect { |ispec| ispec[:instantiation] }).flatten
    end

    # Returns the number of {ISpec}s in current selection.
    # @return [Fixnum]
    def length
      specs.length
    end

    # Returns an array sample ids corresponding to the current selection.
    # @return [Array]
    def sample_ids
      ispecs = get
      s = []
      ispecs.each do |ispec|
        ispec[:instantiation].each do |instance|
          s << extract_id(instance[:sample])
        end
      end
      s
    end

    # Returns an array item ids corresponding to the current selection.
    # @return [Array]
    def item_ids
      ispecs = get
      s = []
      ispecs.each do |ispec|
        ispec[:instantiation].each do |instance|
          s << extract_id(instance[:item])
        end
      end
      s
    end    

    # @!endgroup

    # @!group Chainers

    # Sets the current selection to the operation's input. Can be chained.
    # @return [Op]
    def input;     @parts = []; @type = :inputs;     self; end

    # Sets the current selection to the operation's output. Can be chained.
    # @return [Op]    
    def output;    @parts = []; @type = :outputs;    self; end

    # Sets the current selection to the operation's parameters. Can be chained.
    # @return [Op]    
    def parameter; @parts = []; @type = :parameters; self; end

    # Sets the current selection to the operation's data. Can be chained.
    # @return [Op]    
    def data;      @parts = []; @type = :data;       self; end

    # Selects input, output, parameter, and data. Can be chained.
    # @return [Op]
    def all
      raise "no i/o specified" unless @type == :inputs or @type == :outputs
      @parts = @spec[@type].collect { |i| i[:name] }
      self
    end

    # Sets whether to query the user in subsequent calls to take, release, and produce.
    # @param [Boolean] b
    # @return [Op]
    def query b;   @queryQ = b;         self; end

    # Sets whether to interact with the user in subsequent calls to take, release, and produce.
    # @param [Boolean] b
    # @return [Op]

    def silent b;  @silentQ = b;        self; end

    # Sets the name of the method (currently "list" or "boxes" )
    # to use in subsequent calls to take, release, and produce.
    # 
    # @param [String] m
    # @return [Op]    
    def method m;  @use_method = m;     self; end

    # @!endgroup

    def []=i,val
      @type = :data
      keyval = get
      unless keyval.length == 1
        raise "exactly one (and not zero) data element(s) field can be set at a time. #{options}" 
      end
      keyval[0][:instantiation][i] = { value: val }
    end

    def set(name,val)
      @type = :data
      @parts = [ name ]
      keyval = get
      unless val.class == Array && val.length == keyval[0][:instantiation].length
        raise "#{val} is not an array, or incompatible array sizes when setting data #{name}." 
      end
      keyval[0][:instantiation] = val.collect { |x| { value: x } }
    end     

    def export
      # returns the filled out operation spec
      @spec
    end

  end

  module Base

    # Returns an Op object based on the specification, usually the
    # input to the protocol.
    # @param [Hash] A hash describing the entire operation.
    # @return [Op] 
    # @example Put this at the beginning of your main method.
    #   o = op input
    def op spec
      Op.new spec, self
    end

  end

end