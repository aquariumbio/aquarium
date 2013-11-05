module Plankton

  class Parser

    def statement_list

      while @tok.current != 'EOF'

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

          when @tok.variable
            assign
       
          else
            raise 'Could not find the next statement to parse'

        end

      end

    end # parse

  end

end
