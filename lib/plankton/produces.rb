module Plankton

  class Parser

    def produce ####################################################################################

      @tok.eat_a 'produce'
      data = {}
      rel = nil

      if @tok.next == '=' || @tok.next == '<-'
        var = @tok.eat_a_variable
        @tok.eat
      else
        var = "most_recently_produced_item"
      end

      ob = object_expr

      if @tok.current == 'from'
        @tok.eat_a 'from'
        sample = expr
      end

      note = ""
      location = ""

      while @tok.current != 'end' && @tok.current != 'EOF'

        if @tok.current == 'data'

          @tok.eat_a 'data'

          while @tok.current != 'end' && @tok.current != 'EOF'
            key = @tok.eat_a_variable.to_sym
            @tok.eat_a ':'
            value = expr
            data[key] = value
          end

          @tok.eat_a 'end'

        elsif @tok.current == 'release'

          @tok.eat_a 'release'
          if @tok.current == ':' 
            @tok.eat_a ':'
          end
          rel = expr

        elsif @tok.current == 'note'

          @tok.eat_a 'note'
          if @tok.current == ':' 
            @tok.eat_a ':'
          end
          note = expr

        elsif @tok.current == 'location'

          @tok.eat_a 'location'
          if @tok.current == ':' 
            @tok.eat_a ':'
          end
          location = expr

        else

          raise "Unknown directive in 'produce' at #{@tok.current}"

        end

      end

      @tok.eat_a 'end'

      ins = ProduceInstruction.new ob[:type], ob[:quantity], rel, var
      ins.data_expr = data
      ins.sample_expr = sample
      ins.note_expr = note
      ins.loc_expr = location
      push ins

    end # produce

    def release #####################################################################################

      @tok.eat_a 'release'
      push ReleaseInstruction.new expr

    end # release

  end

end

