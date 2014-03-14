module Oyster

  class Parser

    def argument

      var =  @tok.eat_a_variable
             @tok.eat_a ':'
      type = @tok.eat_a_argtype
      
      unless type == 'number' || type == 'string' || type == 'sample' || type == 'object' || type == 'generic'
        raise "Unknown type '#{type}' in argument"
      end

      if type == 'object' # convert to old type specifier for object types
         type = 'objecttype'
      end

      if type == 'sample'
        if @tok.current == '('
          @tok.eat_a '('
          sample_type = @tok.eat_a_string.remove_quotes
          @tok.eat_a ')'
        else
          sampe_type = ''
        end
      end

      if @tok.current == 'array'
        if type != 'objecttype' && type != 'generic'
          @tok.eat
          type += '_array'
        else
          raise "Cannot have 'objecttype arrays' or 'generic arrays' as arguments."
        end
      end

      if @tok.current == ','
        @tok.eat
        description = @tok.eat_a_string.remove_quotes
      else
        description = ""
      end

      @metacol.arguments.push( { name: var, type: type, description: description, sample_type: sample_type } )
  
    end

    def arguments
      
      @tok.eat_a 'argument'
      while @tok.current != 'end' && @tok.current != 'EOF'
        argument
      end
      @tok.eat_a 'end'

    end

  end

end
