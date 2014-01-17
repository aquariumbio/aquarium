module Plankton

  class Parser

    def simple_type
      if @tok.current == 'number' || @tok.current == 'string'
        return @tok.eat
      else
        raise "Expected 'number' or 'string' at '#{@tok.current}'"
      end
    end

    def optional_description
      if @tok.current == ','
        @tok.eat
        return @tok.eat_a_string.remove_quotes
      else
        return ""
      end
    end

    def optional_choices
      if @tok.current == ','
        @tok.eat
        return expr
      else
        return nil
      end
    end

    def getdata

      getdatas = []

      @tok.eat_a 'getdata'

      while @tok.current != 'end'

        var =  @tok.eat_a_variable
               @tok.eat_a ':'

        type = simple_type
        description = optional_description
        choices = optional_choices
 
        if !choices
          getdatas.push( { getdata: { var: var, 
                                      type: type, 
                                      description: description } } )
        else
          getdatas.push ( { select: { var: var, 
                                      type: type, 
                                      description: description, 
                                      choices: choices } } )
        end

      end

      @tok.eat_a 'end'
      return getdatas

    end # getdata

    def step

      #puts "starting step"
      
      parts = []      
      description = ''
      note = ''
      warnings = []

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'step'

      while @tok.current != 'end'

        case @tok.current

          when 'description', 'note', 'warning', 'bullet', 'check'
            field = @tok.eat.to_sym
            @tok.eat_a ':'
            parts.push({ field => @tok.eat_a_string.remove_quotes})

          when 'getdata'
            parts.concat getdata

          when 'image'
            @tok.eat_a 'image'
            @tok.eat_a ':'
            parts.push( { image: @tok.eat_a_string.remove_quotes } )

          when 'timer'
            @tok.eat_a 'timer'
            @tok.eat_a ':'
            parts.push( { timer: expr } )

          else
            raise "Expected 'description', 'note', 'bullet', 'check', 'warning', 'getdata', 'timer'"
                + "or 'image' at '#{@tok.current}'."
         
        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      push StepInstruction.new parts, lines

      #puts "done with step"

    end

  end

end

