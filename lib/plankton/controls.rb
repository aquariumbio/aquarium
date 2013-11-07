module Plankton

  class Parser

    def if_block #################################################################################

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

    def while_block ###############################################################################

      @tok.eat_a 'while'
      while_pc = pc
      ins = WhileInstruction.new expr, pc+1
      push ins
      statements
      gins = GotoInstruction.new
      gins.mark_destination while_pc
      push gins
      ins.mark_false pc
      @tok.eat_a 'end'

    end # while_block

  end

end
