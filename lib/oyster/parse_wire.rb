module Oyster

  class Parser

    def wire

      @tok.eat_a 'wire'
      from = pair
      @tok.eat_a '=>'
      to = pair

      @metacol.wire from[:place], from[:arg], to[:place], to[:arg]

    end

    def assign

      lhs = @tok.eat_a_variable.to_sym
      @tok.eat_a '='
      { lhs: lhs, rhs: expr }

    end

  end

end
