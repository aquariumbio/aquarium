module Plankton

  class Parser

    def if_block #################################################################################

      # puts "starting if"

      gotos = []

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'if'
      cond = expr
      lines[:endline] = @tok.line
      push PushInstruction.new
      ins = IfInstruction.new cond, lines
      ins.mark_then pc + 1
      push ins

      statements

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

      @tok.eat_a 'end'

      gotos.each do |g|
        g.mark_destination pc
      end

      push PopInstruction.new

    end # if_block

    def while_block ###############################################################################

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'while'
      push PushInstruction.new
      while_pc = pc
      cond = expr
      lines[:endline] = @tok.line
      ins = WhileInstruction.new cond, pc + 1, lines
      push ins
      statements
      gins = GotoInstruction.new
      gins.mark_destination while_pc
      push gins
      ins.mark_false pc
      push PopInstruction.new
      @tok.eat_a 'end'

    end # while_block

    def foreach_block ##############################################################################

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'foreach'
      iterator = @tok.eat_a_variable
      @tok.eat_a 'in'
      array_expr = expr
      lines[:endline] = @tok.line

      temp = "__FOREACH#{@temp_variable_counter}__"
      @temp_variable_counter += 1

      push AssignInstruction.new temp, '0', lines
      push PushInstruction.new
      foreach_pc = pc
      ins = WhileInstruction.new "%{#{temp}} < (#{array_expr}).length", pc + 1, lines
      push ins
      push AssignInstruction.new iterator, "(#{array_expr})[%{#{temp}}]", lines
      statements
      push AssignInstruction.new temp, "%{#{temp}}+1", lines

      gins = GotoInstruction.new
      gins.mark_destination foreach_pc
      push gins
      ins.mark_false pc
      push PopInstruction.new
      @tok.eat_a 'end'

    end # foreach_block

  end

end
