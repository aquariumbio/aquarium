module Plankton

  class Parser

    def log

      @tok.eat_a 'log'

      while @tok.current != 'end' && @tok.current != 'EOF'

        key = @tok.eat_a_variable
        @tok.eat_a ':'
        push LogInstruction.new key, expr, 'log_file'
       
      end

      @tok.eat_a 'end'

    end

  end

end
