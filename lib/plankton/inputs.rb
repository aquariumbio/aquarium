module Plankton

  class Parser

    def input

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'input'

      while @tok.current != 'end' && @tok.current != 'EOF'
        v = @tok.eat_a_variable
        @tok.eat_a '='
        e = expr
        push InputInstruction.new @repo, v, e, lines
      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

    end

  end

end
