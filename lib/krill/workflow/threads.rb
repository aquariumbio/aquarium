module Krill

  # A class that collects all the inputs, outputs, parameters, and data for a particular
  # thread. The most likely situation for encountering a WorkflowThread object is when
  # iterating over all threads in the operation, as in the example below.
  #
  # The main way to use a thread is to use the input, output, data, and parameter selectors,
  # which are method chainers, followed by a name selector. That is, if your operation has an input
  # named x, then you access it via thread.input.x. If you have a parameter named y, then you 
  # access it via thread.parameter.y, and so on.
  #
  # @example Iterate over all threads and show the user the sample id for a particular input named x, assuming o is an instance of {Op}.
  #   show do 
  #     o.threads.each do |thread|
  #       note "#{thread.index}: #{thread.input.x.sample_id}"
  #     end
  #   end
  class WorkflowThread

    # @!visibility private
    attr_accessor :inputs, :outputs, :parameters, :datas

    # Returns the index of the thread in the thread array in which
    # it is contained. 
    # @return [Fixnum]
    # @example Show each thread index to the user.
    #   show do 
    #     o.threads.each do |thread|
    #       note "#{thread.index}"
    #     end
    #   end
    attr_accessor :index

    # @private
    def initialize
      @inputs = {}
      @outputs = {}
      @parameters = {}
      @datas = {}
    end

    # Returns a string representation of the thread showing all
    # inputs, outputs, parameters, and data.
    # @return [String] A string representation of the thread.
    def to_s
      { inputs: @inputs, outputs: @outputs, parameters: @parameters, data: @datas }.to_s
    end

    # Selects the inputs of the thread so that subsequent requests for
    # specific named parts refer to inputs. Returns a WorkflowThread (i.e. is
    # a method chainer).
    #
    # @return [WorkflowThread] The thread it was called on, with inputs selected.
    def input
      @selection = @inputs
      self
    end

    # Selects the outputs of the thread so that subsequent requests for
    # specific named parts refer to outputs. Returns a WorkflowThread (i.e. is
    # a method chainer).
    #
    # @return [WorkflowThread] The thread it was called on, with outputs selected.
    def output
      @selection = @outputs
      self
    end

    # Selects the parameters of the thread so that subsequent requests for
    # specific named parts refer to parameters. Returns a WorkflowThread (i.e. is
    # a method chainer).
    #
    # @return [WorkflowThread] The thread it was called on, with parameters selected.
    def parameter
      @selection = @parameters
      self
    end
    # Selects the data of the thread so that subsequent requests for
    # specific named parts refer to data. Returns a WorkflowThread (i.e. is
    # a method chainer).
    #
    # @return [WorkflowThread] The thread it was called on, with data selected.
    def data
      @selection = @datas
      self
    end

    # For every named part of a thread there is a corresponding method that is
    # dynamically added to thread. For example, if there is an input named 'fragment',
    # then you can call 'fragment' to get an {ISpec} object for that part.
    # 
    # @return [ISpec] The inventory specification for the given part.
    # @example Get the sample id of the input named 'fragment' for the first thread in the [Operation] o.
    #   sid = o.threads.input.fragment.sample_id
    def partname
      raise "Do not use this method directly."
    end

  private

    # @!visibility private
    # This method is used to route part requests and should not be used directly.
    def method_missing name, *args, &block
      if @selection == @inputs || @selection == @outputs
        @selection[name].extend(ISpec) 
      elsif @selection == @datas
        str = name.to_s
        if str =~ /=$/
          name = str[0,str.length-1].to_sym
          raise "Could not find data field named '#{name}' in this operation. Check your spelling, or edit the operation definition in the workflow editor to add this data." unless @selection[name]
          @selection[name][:value] = args[0]
        else
          super
        end
      elsif @selection == @parameters
        @selection[name]
      else
        super        
      end
    end

  end

  # An extension of the Ruby {Array} class with methods that make
  # iterating over threads easier.
  class ThreadArray < Array

    # Spread the array of threads over a {CollectionArray}. 
    # @param [CollectionArray] collections 
    # @param [Hash] opts Currently only skip_occupied: Boolean
    # 
    # @example Suppose o is an {Op} and gels is a {CollectionArray}
    #   o.threads.spread(gels) do |thread,slot|
    #     thread.output.fragment.associate slot
    #   end
    #
    # @example Skip slots in the {CollectionArray} that are filled.
    #   o.threads.spread(gels,skip_occupied:true) do |thread,slot|
    #     thread.output.fragment.associate slot
    #   end
    #
    def spread collections, opts={}

      options =  { skip_occupied: false }.merge opts

      i = 0
      collections.slots.each do |slot|
        if !options[:skip_occupied] || slot.empty?
          if i < self.length
            yield self[i], slot
            i += 1
          end
        end
      end

    end
     
  end

  class Op

    # The number of threads in the operation.
    # @return [Fixnum]
    def num_threads

      parts = (@spec[:inputs] + @spec[:outputs] + @spec[:parameters] + @spec[:data]).reject do |ispec|
        ispec[:shared]
      end

      if parts.length == 0
        0
      else
        parts.first[:instantiation].length
      end

    end

    # An array of the (non-shared) threads in the operation.
    # @return [ThreadArray]
    def threads

      unless @thread_array 

        @thread_array = ThreadArray.new

        num_threads.times do |index|

          t = WorkflowThread.new

          t.index = index

          (@spec[:inputs].reject { |i| i[:shared] }).each do |i| 
            t.inputs[i[:name].to_sym] = i[:instantiation][index]
          end

          (@spec[:outputs].reject { |o| o[:shared] }).each do |o| 
            t.outputs[o[:name].to_sym] = o[:instantiation][index]
          end

          @spec[:parameters].each do |p| 
            t.parameters[p[:name].to_sym] = p[:instantiation][index]
          end             

          @spec[:data].each do |d| 
            t.datas[d[:name].to_sym] = d[:instantiation][index]
          end             

          @thread_array << t

        end

      end

      @thread_array

    end

  end

end