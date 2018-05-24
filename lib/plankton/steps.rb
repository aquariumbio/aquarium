module Plankton

  class Parser

    def simple_type
      if @tok.current == 'number' || @tok.current == 'string'
        @tok.eat
      else
        raise "Expected 'number' or 'string' at '#{@tok.current}'"
      end
    end

    def optional_description
      if @tok.current == ','
        @tok.eat
        expr
      else
        ''
      end
    end

    def optional_choices
      if @tok.current == ','
        @tok.eat
        expr
      end
    end

    def getdata

      parts = []

      if @tok.current == 'getdata'
        @tok.eat_a 'getdata'
      else
        @tok.eat_a 'input'
      end

      while @tok.current != 'end'

        var = @tok.eat_a_variable
        @tok.eat_a ':'

        type = simple_type
        description = optional_description
        choices = optional_choices

        if !choices
          parts.push(flavor: :get,
                     var: var,
                     type: type,
                     description: description)
        else
          parts.push ( { flavor: :select,
                         var: var,
                         type: type,
                         description: description,
                         choices: choices })
        end

      end

      @tok.eat_a 'end'

      { type: :input, parts: parts }

    end

    def step_foreach

      fe = { type: :foreach, statements: [] }

      @tok.eat_a 'foreach'
      fe[:iterator] = @tok.eat_a_variable.to_sym
      @tok.eat_a 'in'
      fe[:list] = expr

      fe[:statements].push step_statement while @tok.current != 'end'

      @tok.eat_a 'end'

      fe

    end

    def step_statement

      s = {}

      case @tok.current

      when 'description', 'note', 'warning', 'bullet', 'check', 'image', 'timer', 'table'
        s[:type] = @tok.eat.to_sym
        @tok.eat_a ':'
        s[:expr] = expr # should check that this evaluates to the right thing in pre_render

      when 'getdata', 'input'
        s = getdata

      when 'foreach'
        s = step_foreach

      else
        raise "Unknown field '#{@tok.current}' in step"

      end

      s

    end

    def step

      statements = []

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'step'

      statements.push step_statement while @tok.current != 'end'

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      push StepInstruction.new statements, lines

    end

  end

end
