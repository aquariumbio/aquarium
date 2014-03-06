module Plankton

  class Parser

    def statements

      while @tok.current != 'end' && @tok.current != 'elsif' && @tok.current != 'else'

        if @tok.current == 'EOF' && @include_stack.length > 1

          #puts "about to pop with current = '#{@tok.current}'"
          p = @include_stack.pop

          @tok = @include_stack.last[:tokens]
          push EndIncludeInstruction.new p[:returns]
          #puts "popped, now inc length = #{@include_stack.length} with current = '#{@tok.current}'"

        elsif @tok.current == 'EOF' 

          return

        end

        case @tok.current

          when 'EOF'
            return

          when 'information'
            information

          when 'argument'
            argument_list

          when 'step'
            step

          when 'take'
            take

          when 'produce'
            produce

          when 'modify'
            modify

          when 'release'
            release

          when 'log'
            log

          when 'input'
            input

          when 'if'
            if_block

          when 'while'
            while_block

          when 'foreach'
            foreach_block

          when 'function'
            function_def

          when 'return'
            return_statement

          when 'http'
            http

          when 'include', 'require'
            include

          when 'end', 'elsif', 'else'
            return

          when 'local'
            basic_statement

          else
            basic_statement

        end

      end

    end # statements

    def information
   
      @tok.eat_a 'information'
      push InformationInstruction.new string_expr

    end # information

  end

end
