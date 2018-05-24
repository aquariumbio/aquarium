module Plankton

  class Parser

    def log

      @tok.eat_a 'log'

      while @tok.current != 'end' && @tok.current != 'EOF'

        lines = {}
        lines[:startline] = @tok.line
        key = @tok.eat_a_variable
        @tok.eat_a ':'
        lines[:endline] = @tok.line
        push LogInstruction.new key, expr, 'log_file', lines

      end

      @tok.eat_a 'end'

    end

  end

end
