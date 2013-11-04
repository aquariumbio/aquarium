module Plankton

  class Parser

    def argument
  
      var =  @tok.eat_a_variable
             @tok.eat_a ':'
      type = @tok.eat_a_argtype
      
      if type == 'object' # convert to old type specifier for object types
         type = 'objecttype'
      end

      if @tok.current == ','
        @tok.eat
        description = @tok.eat_a_string.remove_quotes
      else
        description = ""
      end

      if !@include_stack
        raise "For some reason the include stack is not defined"
      end

      if @include_stack.length <= 1
        push_arg ArgumentInstruction.new var, type, description
      end
  
      # puts "ARG: #{var} : #{type}, #{description}"

    end # argument

    def argument_list
      
      @tok.eat_a 'argument'
      while @tok.current != 'end' && @tok.current != 'EOF'
        argument
      end
      @tok.eat_a 'end'

      return true

    end # argument_list

    def parse_arguments_only

      while @tok.current != 'EOF'

        while @tok.current != 'EOF' && @tok.current != 'argument'
          @tok.eat
        end

        if @tok.current == 'argument'
          argument_list
        end

      end

    end # arguments_only

  end 

end
