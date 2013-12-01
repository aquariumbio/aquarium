module Plankton

  class Parser

    def assign
    
      lines = {}
      lines[:startline] = @tok.line
 
      lhs = @tok.eat_a_variable
      @tok.eat_a '='
      lines[:endline] = @tok.line
      rhs = expr

      push AssignInstruction.new lhs, rhs, lines

    end

  end

end
