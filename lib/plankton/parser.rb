module Plankton

  class Parser < Lang::Parser

    attr_reader :program, :args, :info, :include_stack, :debug
    attr_writer :job_id

    def initialize name, contents

      @tok = Lang::Tokenizer.new ( contents )
      @program = []
      @args = []
      @include_stack = [ { tokens: @tok, path: name, returns: [] } ]
      @info = ""
      @debug = "No debug info available"
      @job_id = -1

      # Array functions
      add_function :length, 1
      add_function :append, 2
      add_function :concat, 2
      add_function :unique, 1
      
      # Collection functions
      add_function :collection, 1

    end

    def bad_xml
      line.to_s + ": " + @tok.get_line
    end

    def line
      @tok.line
    end

    def pc
      @program.length
    end

    def push i
      i.pc = @program.length
      @program.push i
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
    end

    def parse
      statements
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

