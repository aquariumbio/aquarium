module Plankton

  class Parser < Lang::Parser

    attr_reader :program, :args, :info, :include_stack, :debug
    attr_writer :job_id, :function_callback

    def initialize name, contents

      # puts "New Parser with contents = #{contents}"

      @tok = Lang::Tokenizer.new ( contents )
      @program = []
      @function_space = []
      @function_pointers = []
      @args = []
      @include_stack = [ { tokens: @tok, path: name, returns: [] } ]
      @info = ""
      @debug = "No debug info available"
      @job_id = -1

      # user defined functions 
      @function_callback = method(:function_call) # used in the app method of expressions
      @function_space = []                        # temporary space where function defintions are put
      @function_specs = {}                        # map from function names to function_space locations and arg specs
      @in_function_def = false                    # whether parsing in or out of a function definition
      @function_call_num = 0

      # Temporary variables
      @temp_variable_counter = 0

      super()

    end

    def bad_xml
      line.to_s + ": " + @tok.get_line
    end

    def line
      @tok.line
    end

    def pc
      if @in_function_def
        @function_space.length
      else
        @program.length
      end
    end

    def push i
      if @in_function_def 
        i.pc = @function_space.length
        @function_space.push i
      else
        i.pc = @program.length
        @program.push i
      end
    end

    def last
      if @in_function_def 
        @function_space.last
      else
        @program.last
      end
    end
    
    def push_arg a
      @args.push a
    end

    def show
      pc = 0
      @program.each do |i|
        puts pc.to_s + ": " + i.to_s
        pc += 1
      end
      @function_specs.each do |k,v|
        puts "#{k}: #{v}"
      end
    end

    def parse
      push StartInstruction.new
      statements
      append_function_space
    end

    def get_line
      @include_stack.last[:path] + ': ' + @tok.get_line
    end

    def get_file path
 
      begin
        file = Blob.get_file @job_id, path
      rescue Exception => e
        raise "Could not find file '#{path}': " + e.to_s
      end
    
      return file

    end

  end

end

