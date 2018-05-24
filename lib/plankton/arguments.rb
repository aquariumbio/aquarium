module Plankton

  class Parser

    def argument

      var = @tok.eat_a_variable
      @tok.eat_a ':'
      type = @tok.eat_a_argtype

      raise "Unknown type '#{type}' in argument." unless type == 'number' || type == 'string' || type == 'sample' || type == 'object' || type == 'generic'

      type = 'objecttype' if type == 'object' # convert to old type specifier for object types

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
        description = ''
      end

      raise 'For some reason the include stack is not defined.' unless @include_stack

      if @include_stack.length <= 1
        a = ArgumentInstruction.new var, type, description
        a.sample_type = sample_type if sample_type
        push_arg a
      end

    end # argument

    def argument_list

      @tok.eat_a 'argument'
      argument while @tok.current != 'end' && @tok.current != 'EOF'
      @tok.eat_a 'end'

      true

    end # argument_list

    def parse_arguments_only

      while @tok.current != 'EOF'

        @tok.eat while @tok.current != 'EOF' && @tok.current != 'argument'

        argument_list if @tok.current == 'argument'

      end

    end # arguments_only

  end

end
