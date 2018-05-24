module Plankton

  class Parser

    def assign_old

      lines = {}
      lines[:startline] = @tok.line

      if @tok.current == 'local'
        @tok.eat_a 'local'
        local = true
      else
        local = false
      end

      lhs = @tok.eat_a_variable

      if local && @tok.current != '='
        rhs = 'false'
      else
        @tok.eat_a '='
        lines[:endline] = @tok.line
        rhs = expr
      end

      push AssignInstruction.new lhs, rhs, lines.merge({ new: local })

    end

    def basic_statement_old

      if @tok.current == 'local' || @tok.next == '='

        assign

      else

        lines = {}
        lines[:startline] = @tok.line
        e = expr
        lines[:endline] = @tok.line

        push AssignInstruction.new '__DUMMY_VARIABLE__', e, lines

      end

    end

    def basic_statement

      lines = {}
      lines[:startline] = @tok.line

      if @tok.current == 'local'
        @tok.eat_a 'local'
        local = true
      else
        local = false
      end

      lhs = expr

      if @tok.current == '='

        # Check that lhs is proper. Throw away parts.
        temp_lhs = lhs.gsub /%{([a-zA-Z][a-zA-Z_0-9]*)}/, '\1'
        temp_parser = Plankton::Parser.new("n/a", temp_lhs)
        temp_parser.get_lhs_parts

        @tok.eat_a '='
        rhs = expr

      elsif local # in this case the expression is of the form 'local x'

        rhs = 'false'

      else

        rhs = lhs
        lhs = '__DUMMY_VARIABLE__'

      end

      lines[:endline] = @tok.line

      push AssignInstruction.new lhs, rhs, lines.merge({ new: local })

    end

  end

end
