module Plankton

  class Parser

    def modify

      lines = {}
      lines[:startline] = @tok.line
      @tok.eat_a 'modify'

      info = { item: expr }

      keys = [:location, :inuse, :dinuse, :iinuse, :quantity, :dquantity, :iquantity]

      while @tok.current != 'end' && @tok.current != 'EOF'

        if keys.include? @tok.current.to_sym

          k = @tok.eat.to_sym
          @tok.eat_a ':'
          info[k] = expr

        else

          raise "Expected #{keys} in 'modify' block at #{@tok.current}."

        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      push ModifyInstruction.new info, lines

    end # modify

  end

end
