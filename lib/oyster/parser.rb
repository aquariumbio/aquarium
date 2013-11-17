module Oyster

  class Parser < Lang::Parser

    def initialize contents
      @tok = Lang::Tokenizer.new contents 
      add_function :completed, 1
      @metacol = Metacol.new
    end

    def parse
      statements
      @metacol
    end

    def place
       
      @tok.eat_a 'place'
      p = Place.new

      v = @tok.eat_a_variable

      while @tok.current != 'end'

        case @tok.current

          when 'protocol'

            @tok.eat_a 'protocol'
            @tok.eat_a ':'
            p.proto( eval expr)

          when 'group'

            @tok.eat_a 'group'
            @tok.eat_a ':'
            p.group( eval expr)

          when 'marked'

            @tok.eat_a 'marked'
            @tok.eat_a ':'
            if eval expr
              p.mark
            end

          else
            raise "Unknown field '#{@tok.current}"

        end

      end

      @metacol.place p
      puts "added a place"

      @tok.eat_a 'end'

    end

    def place_list

      pl = []
      @tok.eat_a '['
      while @tok.current != ']'
        pl.push @tok.eat_a_variable
        if @current == ','
          @tok.eat_a ','
        end
      end
      @tok.eat_a ']'

    end

    def trans

      parents = place_list
      @tok.eat_a '=>'
      children = place_list
      @tok.eat_a 'when'
      cond = expr
      @tok.eat_a 'end'

    end

    def pair
      p = {}
      @tok.eat_a '('
      p[:place] = @tok.eat_a_variable
      @tok.eat_a ','
      p[:place] = @tok.eat_a_string
      @tok.eat_a ')'
      p
    end

    def wire
      from = pair
      @tok.eat_a '=>'
      to = pair
    end

    def statements

      while @tok.current != 'EOF'

        case @tok.current

          when 'place'
            place

          when '['
            trans

          when '('
            wire

#          else
#            assign

        end

      end

    end

  end

end
