module Plankton

  class Parser

    def if_block #################################################################################

      #puts "starting if"

      gotos = []

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'if'
      cond = expr
      lines[:endline] = @tok.line
      ins = IfInstruction.new cond, lines
      ins.mark_then pc + 1
      push ins

      #puts "read condition, starting statements"

      statements

      #puts "finished statements"

      g = GotoInstruction.new 
      push g
      gotos.push g

      while @tok.current == 'elsif'

        lines = {}
        lines[:startline] = @tok.line
        @tok.eat_a 'elsif'
        ins.mark_else pc
        cond = expr
        lines[:endline] = @tok.line
        ins = IfInstruction.new cond, lines
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

      #puts "looking for the end"

      @tok.eat_a 'end'

      #puts "found the end"

      gotos.each do |g|
        g.mark_destination pc
      end

    end # if_block

    def while_block ###############################################################################

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'while'
      while_pc = pc
      cond = expr
      lines[:endline] = @tok.line
      ins = WhileInstruction.new cond, pc+1, lines
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
