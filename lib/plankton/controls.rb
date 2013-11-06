module Plankton

  class Parser

    def if_block

      gotos = []

      @tok.eat_a 'if'
      ins = IfInstruction.new expr
      ins.mark_then pc + 1
      push ins

      statements

      g = GotoInstruction.new 
      push g
      gotos.push g

      while @tok.current == 'elsif'

        @tok.eat_a 'elsif'
        ins.mark_else pc
        ins = IfInstruction.new expr
        ins.mark_then pc + 1
        push ins

        statements

        g = GotoInstruction.new 
        push g
        gotos.push g

      end

      ins.mark_else pc

      if @tok.current == 'else'
        @tok.eat_a 'else'
        statements
      end 

      @tok.eat_a 'end'

      gotos.each do |g|
        g.mark_destination pc
      end

    end # if_block

  end

end
