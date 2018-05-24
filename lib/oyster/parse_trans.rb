module Oyster

  class Parser

    def place_list

      pl = []
      @tok.eat_a '['
      while @tok.current != ']' && @tok.current != 'EOF'
        pl.push @metacol.scope.evaluate expr
        if @tok.current != ']'
          @tok.eat_a ','
        end
      end
      @tok.eat_a ']'

      pl

    end

    def assigns

      a = []
      @tok.eat_a 'do'

      while @tok.current != 'end' && @tok.current != 'EOF'
        a.push assign
      end

      @tok.eat_a 'end'

      a

    end

    def trans

      t = Transition.new

      @tok.eat_a 'transition'
      parents = place_list
      @tok.eat_a '=>'
      children = place_list
      @tok.eat_a 'when'
      if @tok.current == ':'
        @tok.eat_a ':'
      end
      cond = expr

      if @tok.current == 'do'
        t.prog assigns
      end

      @tok.eat_a 'end'

      parents.each do |i|
        t.parent @metacol.places[i]
      end

      children.each do |i|
        t.child @metacol.places[i]
      end

      t.cond cond
      @metacol.transition t

    end

  end

end
