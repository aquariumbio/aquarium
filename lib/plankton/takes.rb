module Plankton

  class Parser

    def item_expr ################################################################################################

      # TODO THIS PART SHOULD BE AN EXPRESSION
      @tok.eat_a 'item'
      return expr     

    end # item_expr

    def object_expr ##############################################################################################

      quantity = expr

      type = expr
      return { quantity: quantity, type: type }

    end # object_expr

    def take_assign ##############################################################################################

      var = @tok.eat_a_variable

      if @tok.current == '=' || @tok.current == '<-'
        op = @tok.eat
      else
        raise "Expected '=' or '<-' at '#{@tok.current}'."
      end

      if @tok.current == 'item'
        item = item_expr
        return { var: var, op: op, item: item }
      else
        ob = object_expr
        return { var: var, op: op, object: ob }
      end

    end # take_assign

    def take #################################################################################

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'take'
      items = []
      note = ""

      while @tok.current != 'end' && @tok.current != 'EOF'

        if @tok.current == 'item'

          items.push( { var: "most_recently_taken_item", id: item_expr } )

        elsif @tok.current == 'note'

          @tok.eat_a 'note'
          @tok.eat_a ':'
          note = @tok.eat_a_string.remove_quotes

        elsif @tok.next == '=' || @tok.next == '<-'

          ta = take_assign
          if ta[:object]
            items.push( { 
              var: ta[:var], 
              op: ta[:op], 
              quantity: ta[:object][:quantity], 
              type: ta[:object][:type] } )
          else
            items.push( { 
              var: ta[:var], 
              op: ta[:op], 
              id: ta[:item] } )
          end

        else

          ob = object_expr
          items.push( { 
            var: "most_recently_taken_item", 
            quantity: ob[:quantity], 
            type: ob[:type] } )

        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      ti = TakeInstruction.new items, lines
      ti.note_expr = note
      push ti

    end

  end # take

end
