module Plankton

  class Parser

    def assign
    
      lines = {}
      lines[:startline] = @tok.line
 
      if @tok.current == 'local'
        @tok.eat_a 'local'
        local = true
      else
        local = false
      end

      lhs = @tok.eat_a_variable

      if local && @tok.current != '='
        rhs = 'false'
      else
        @tok.eat_a '='
        lines[:endline] = @tok.line
        rhs = expr
      end

      push AssignInstruction.new lhs, rhs, lines.merge({new: local})

    end

    def basic_statement

      if @tok.current == 'local' || @tok.next == '='

        assign

      else
    
        lines = {}
        lines[:startline] = @tok.line
        e = expr
        lines[:endline] = @tok.line

        push AssignInstruction.new '__DUMMY_VARIABLE__', e, lines

      end

    end

  end

end
