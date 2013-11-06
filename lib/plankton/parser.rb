module Plankton

  class Parser

    attr_reader :program, :args, :info, :bad_xml, :include_stack, :debug
    attr_writer :job_id

    def initialize file
      @tok = Tokenizer.new ( file )
      @program = []
      @args = []
      @include_stack = []
      @info = ""
      @bad_xml = "BioTurk thinks plankton uses xml. Silly bioturk."
      @debug = "No debug info available"
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

  end

end
