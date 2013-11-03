module Plankton

  class Parser

    def assign
    
      lhs = @tok.eat_a_variable
      @tok.eat_a '='
      rhs = expr

      push AssignInstruction.new lhs, rhs

    end

  end

end
