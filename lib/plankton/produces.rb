# frozen_string_literal: true

module Plankton

  class Parser

    def produce ####################################################################################

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'produce'
      data = {}
      rel = nil

      if @tok.current == 'silently'
        @tok.eat_a 'silently'
        render = false
      else
        render = true
      end

      if @tok.next == '=' || @tok.next == '<-'
        var = @tok.eat_a_variable
        @tok.eat
      else
        var = 'most_recently_produced_item'
      end

      ob = object_expr

      if @tok.current == 'from'
        @tok.eat_a 'from'
        sample = expr
      end

      if @tok.current == 'of'
        @tok.eat_a 'of'
        sample_name = expr
      end

      note = ''
      location = ''

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
          @tok.eat_a ':' if @tok.current == ':'
          rel = expr

        elsif @tok.current == 'note'

          @tok.eat_a 'note'
          @tok.eat_a ':' if @tok.current == ':'
          note = expr

        elsif @tok.current == 'location'

          @tok.eat_a 'location'
          @tok.eat_a ':' if @tok.current == ':'
          location = expr

        else

          raise "Unknown directive in 'produce' at #{@tok.current}"

        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      ins = ProduceInstruction.new ob[:type], ob[:quantity], rel, var, lines
      ins.data_expr = data
      ins.sample_expr = sample
      ins.sample_name_expr = sample_name
      ins.note_expr = note
      ins.loc_expr = location
      ins.renderable = render
      push ins

    end # produce

    def release #####################################################################################

      @tok.eat_a 'release'
      push ReleaseInstruction.new expr

    end # release

  end

end
