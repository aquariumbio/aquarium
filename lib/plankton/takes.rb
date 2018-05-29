# frozen_string_literal: true

module Plankton

  class Parser

    def item_expr ################################################################################################

      # TODO: THIS PART SHOULD BE AN EXPRESSION
      @tok.eat_a 'item'
      expr

    end # item_expr

    def object_expr ##############################################################################################

      quantity = expr
      type = expr
      { quantity: quantity, type: type }

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
      entry_list = []
      note = ''

      while @tok.current != 'end' && @tok.current != 'EOF'

        if @tok.current == 'item'

          entry_list.push TakeEntry.new var: 'most_recently_taken_item', item_expr: item_expr

        elsif @tok.current == 'note'

          @tok.eat_a 'note'
          @tok.eat_a ':'
          note = expr

        elsif @tok.next == '='

          ta = take_assign

          if ta[:object]
            puts 'C'
            entry_list.push TakeEntry.new(
              var: ta[:var],
              quantity_expr: ta[:object][:quantity],
              type_expr: ta[:object][:type]
            )

          else

            entry_list.push TakeEntry.new(
              var: ta[:var],
              item_expr: ta[:item]
            )

          end

        else

          ob = object_expr

          entry_list.push TakeEntry.new(
            var: 'most_recently_taken_item',
            quantity_expr: ob[:quantity],
            type_expr: ob[:type]
          )

        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      ti = TakeInstruction.new entry_list, lines
      ti.note_expr = note
      push ti

    end

  end # take

end
