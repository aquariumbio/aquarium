module Plankton

  class Parser

    def statements

      while @tok.current != 'EOF' && @tok.current != 'end' && @tok.current != 'elsif' && @tok.current != 'else'

        case @tok.current

          when 'argument'
            argument_list

          when 'step'
            step

          when 'take'
            take

          when 'produce'
            produce

          when 'release'
            release

          when 'log'
            log

          when 'if'
            if_block

          when @tok.variable
            assign
       
          else
            raise 'Could not find the next statement to parse'

        end

      end

    end # parse

  end

end
