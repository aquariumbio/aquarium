module Plankton

  class Parser

    def assign
    
      var = @tok.eat_a_variable
      @tok.eat_a '='
      rhs = expr

      puts "ASSIGN: #{var} = #{rhs}"

    end

  end

end
