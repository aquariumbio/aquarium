module Oyster

  class Parser < Lang::Parser

    attr_reader :scope

    def initialize contents
      @tok = Lang::Tokenizer.new contents 
      add_function :completed, 1
      @metacol = Metacol.new
      @scope = Scope.new
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
            p.proto( @scope.evaluate expr)

          when 'group'

            @tok.eat_a 'group'
            @tok.eat_a ':'
            p.group( @scope.evaluate expr)

          when 'marked'

            @tok.eat_a 'marked'
            @tok.eat_a ':'
            if @scope.evaluate expr
              p.mark
            end

          else
            raise "Unknown field '#{@tok.current}"

        end

      end

      @scope.set v.to_sym, @metacol.places.length
      @metacol.place p
      puts "added a place: #{p.protocol}"

      @tok.eat_a 'end'

    end

    def place_list

      pl = []
      @tok.eat_a '['
      while @tok.current != ']'
        pl.push @scope.evaluate expr
        if @current == ','
          @tok.eat_a ','
        end
      end
      @tok.eat_a ']'

      pl

    end

    def trans

      parents = place_list
      @tok.eat_a '=>'
      children = place_list
      @tok.eat_a 'when'
      cond = @scope.substitute expr
      @tok.eat_a 'end'
  
      t = Transition.new

      parents.each do |i|
        t.parent @metacol.places[i]
      end

      children.each do |i|
        t.child @metacol.places[i]
      end

      t.cond cond
      @metacol.transition t

    end

    def pair
      p = {}
      @tok.eat_a '('
      p[:place] = @scope.evaluate expr
      @tok.eat_a ','
      p[:arg] = @scope.evaluate expr
      @tok.eat_a ')'
      p
    end

    def wire

      from = pair
      @tok.eat_a '=>'
      to = pair

      @metacol.wire from[:place], from[:arg], to[:place], to[:arg]

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
