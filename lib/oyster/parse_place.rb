# frozen_string_literal: true

module Oyster

  class Parser

    def arg_list

      args = {}
      @tok.eat_a 'argument'

      while @tok.current != 'end' && @tok.current != 'EOF'
        sym = @tok.eat_a_variable.to_sym
        @tok.eat_a ':'
        args[sym] = expr
      end

      @tok.eat_a 'end'
      # puts "returning #{args}"
      args

    end

    def place

      @tok.eat_a 'place'
      p = Place.new
      v = @tok.eat_a_variable
      p.name = v

      while @tok.current != 'end' && @tok.current != 'EOF'

        case @tok.current

        when 'protocol'

          @tok.eat_a 'protocol'
          @tok.eat_a ':'
          path = @metacol.scope.evaluate expr
          if /:/ =~ path
            p.proto path.split(':').join('/')
          else
            p.proto(@default_repo + '/' + path)
          end

        when 'group'

          @tok.eat_a 'group'
          @tok.eat_a ':'
          p.group(expr)

        when 'marked'

          @tok.eat_a 'marked'
          @tok.eat_a ':'
          p.mark if @metacol.scope.evaluate expr

        when 'start'

          @tok.eat_a 'start'
          @tok.eat_a ':'
          p.desired time

        when 'window'

          @tok.eat_a 'window'
          @tok.eat_a ':'
          p.window time

        when 'argument'
          p.arg_expressions = arg_list

        else
          raise "Unknown field '#{@tok.current}"

        end

      end

      @metacol.scope.set v.to_sym, @metacol.places.length
      @metacol.place p
      # puts "added a place: #{p.protocol}"

      @tok.eat_a 'end'

    end

  end

end
