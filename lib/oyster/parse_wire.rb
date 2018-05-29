# frozen_string_literal: true

module Oyster

  class Parser

    def pair
      p = {}
      @tok.eat_a '('
      p[:place] = @metacol.scope.evaluate expr
      @tok.eat_a ','
      p[:arg] = @tok.eat_a_string.remove_quotes
      @tok.eat_a ')'
      p
    end

    def wire

      @tok.eat_a 'wire'

      if @tok.current == '('

        from = pair
        @tok.eat_a '=>'
        to = pair

        @metacol.wire from[:place], from[:arg], to[:place], to[:arg]

      else

        from = @metacol.scope.evaluate expr
        @tok.eat_a '=>'
        to = @metacol.scope.evaluate expr

        @metacol.wire from, '*', to, '*'

      end

    end

    def assign

      lhs = @tok.eat_a_variable.to_sym
      @tok.eat_a '='
      { lhs: lhs, rhs: expr }

    end

  end

end
