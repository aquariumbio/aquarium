module Plankton

  class Parser

    def initialize str
      @tok = Tokenizer.new ( str )
    end

    def parse

      while @tok.current != 'EOF'

        case @tok.current

          when 'argument'
            argument_list

          when 'step'
            step

          when @tok.variable
            assign
       
          else
            raise 'Could not find the next statement to parse'

        end

      end

    end # parse

  end

end
