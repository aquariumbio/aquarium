module Plankton

  class Parser

    def statements

      while @tok.current != 'EOF' && @tok.current != 'end' && @tok.current != 'elsif' && @tok.current != 'else'

        case @tok.current

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

          when 'if'
            if_block

          when 'while'
            while_block

          when 'http'
            http

          when 'include'
            include

          when @tok.variable
            assign
       
          else
            raise 'Could not find the next statement to parse'

        end

      end

    end # parse

    def information
   
      @tok.eat_a 'information'
      push InformationInstruction.new string_expr

    end # information

  end

end
