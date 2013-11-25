module Plankton

  class Parser

    def modify

      @tok.eat_a 'modify'

      info = { item: expr }

      while @tok.current != 'end' && @tok.current != 'EOF'

        if @tok.current == 'location'

           @tok.eat_a 'location'
           @tok.eat_a ':'
           info[:location] = expr
 
        elsif @tok.current == 'inuse'

           @tok.eat_a 'inuse'
           @tok.eat_a ':'
           info[:inuse] = expr

        elsif @tok.current == 'quantity'

           @tok.eat_a 'quantity'
           @tok.eat_a ':'
           info[:quantity] = expr

        else
          raise "Expected either 'location', 'inuse', or 'quantity' field in 'modify' block at #{@tok.current}."
        end

      end

      @tok.eat_a 'end'

      push ModifyInstruction.new info

    end # modify

  end

end
