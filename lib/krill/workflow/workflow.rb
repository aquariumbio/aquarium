module Krill

  class Op

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

    # GETTERS #############################################################

    def name
      @spec[:name]
    end

    def input_names;     @spec[:inputs].collect { |i| i[:name] };     end
    def output_names;    @spec[:outputs].collect { |i| i[:name] };    end
    def parameter_names; @spec[:parameters].collect { |i| i[:name] }; end
    def data_names;      @spec[:data].collect { |i| i[:name] };       end

    def part_names
      input_names + output_names + parameter_names + data_names
    end

    def get
      raise "no type specified." unless @type
      type = @spec[@type]
      raise "operation's #{@type} not found." unless type
      @parts.collect do |part|
        type.find { |i| i[:name] == part }
      end
    end

    def instances
      (get.collect { |part| part[:instantiation] }).flatten
    end

    def options
      { type: @type, parts: @parts, query: @queryQ, silent: @silentQ, method: @use_method, index: @index }
    end  

    def get_ispec_io
      unless @type == :inputs || @type == :outputs
        raise "No i/o specified. Call .input or .output first." 
      end
      get
    end    

    def result
      @spec
    end

    def samples
      ispecs = get
      s = []
      ispecs.each do |ispec|
        ispec[:instantiation].each do |instance|
          s << instance[:sample]
        end
      end
      s
    end

    def items
      ispecs = get
      s = []
      ispecs.each do |ispec|
        ispec[:instantiation].each do |instance|
          s << instance[:item]
        end
      end
      s
    end    

    # CHAINERS ############################################################

    def input;     @parts = []; @type = :inputs;     self; end
    def output;    @parts = []; @type = :outputs;    self; end
    def parameter; @parts = []; @type = :parameters; self; end
    def data;      @parts = []; @type = :data;       self; end

    def all
      raise "no i/o specified" unless @type == :inputs or @type == :outputs
      @parts = @spec[@type].collect { |i| i[:name] }
      self
    end

    def query b;   @queryQ = b;         self; end
    def silent b;  @silentQ = b;        self; end
    def method m;  @use_method = m;     self; end

    # DOERS ###############################################################

    def []=i,val
      @type = :data
      keyval = get
      unless keyval.length == 1
        raise "exactly one (and not zero) data element(s) field can be set at a time. #{options}" 
      end
      keyval[0][:instantiation][i] = { value: val }
      puts "#{keyval[0]}"      
    end

    def set(name,val)
      @type = :data
      @parts = [ name ]
      keyval = get
      unless val.class == Array && val.length == keyval[0][:instantiation].length
        raise "#{val} is not an array, or incompatible array sizes when setting data #{name}." 
      end
      keyval[0][:instantiation] = val.collect { |x| { value: x } }
      puts "#{keyval[0]}"      
    end     

    # RETURN VALUE ########################################################

    def export
      # returns the filled out operation spec
      puts "Exporting"
      @spec
    end

  end

  module Base

    def op spec
      Op.new spec, self
    end

  end

end