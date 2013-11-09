module Plankton

  class Parser

    attr_reader :program, :args, :info, :bad_xml, :include_stack, :debug
    attr_writer :job_id

    def initialize file
      @tok = Tokenizer.new ( file )
      @program = []
      @args = []
      @include_stack = [ { tokens: @tok, path: '', returns: [] } ]
      @info = ""
      @bad_xml = "BioTurk thinks plankton uses xml. Silly bioturk."
      @debug = "No debug info available"
      @job_id = 0
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

      while @include_stack.length > 0

        statements

        p = @include_stack.pop

        if @include_stack.length > 0
          @tok = @include_stack.last[:tokens]
          push EndIncludeInstruction.new p[:returns]
          puts "inc length = #{@include_stack.length} with current = #{@tok.current}"
        end

      end

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
