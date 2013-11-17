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

    def arg_list

      args = {}
      @tok.eat_a 'argument'

      while @tok.current != 'end' && @tok.current != 'EOF'
        sym = @tok.eat_a_variable.to_sym
        @tok.eat_a ':'
        args[sym] = { e: expr, v: nil } # expression(e) kept so it can be reevaluated over and over
                                        # value(v) not found until submission time
      end

      @tok.eat_a 'end'
      puts "returning #{args}"
      args

    end

    def place
       
      @tok.eat_a 'place'
      p = Place.new

      v = @tok.eat_a_variable

      while @tok.current != 'end' && @tok.current != 'EOF'

        case @tok.current

          when 'protocol'

            @tok.eat_a 'protocol'
            @tok.eat_a ':'
            p.proto( @metacol.scope.evaluate expr)

          when 'group'

            @tok.eat_a 'group'
            @tok.eat_a ':'
            p.group( @metacol.scope.evaluate expr)

          when 'marked'

            @tok.eat_a 'marked'
            @tok.eat_a ':'
            if @metacol.scope.evaluate expr
              p.mark
            end

          when 'argument'
             p.arguments = arg_list

          else
            raise "Unknown field '#{@tok.current}"

        end

      end

      @metacol.scope.set v.to_sym, @metacol.places.length
      @metacol.place p
      puts "added a place: #{p.protocol}"

      @tok.eat_a 'end'

    end

    def place_list

      pl = []
      @tok.eat_a '['
      while @tok.current != ']'
        pl.push @metacol.scope.evaluate expr
        if @current == ','
          @tok.eat_a ','
        end
      end
      @tok.eat_a ']'

      pl

    end

    def assigns

      a = []
      @tok.eat_a 'do'

      while @tok.current != 'end' && @tok.current != 'EOF'
        a.push assign
      end

      @tok.eat_a 'end'

      a

    end

    def trans

      t = Transition.new

      @tok.eat_a 'transition'
      parents = place_list
      @tok.eat_a '=>'
      children = place_list
      @tok.eat_a 'when'
      cond = expr

      if @tok.current == 'do'
        t.prog assigns
      end

      @tok.eat_a 'end'
  
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
      p[:place] = @metacol.scope.evaluate expr
      @tok.eat_a ','
      p[:arg] = @metacol.scope.evaluate expr
      @tok.eat_a ')'
      p
    end

    def wire

      @tok.eat_a 'wire'
      from = pair
      @tok.eat_a '=>'
      to = pair

      @metacol.wire from[:place], from[:arg], to[:place], to[:arg]

    end

    def assign

      lhs = @tok.eat_a_variable.to_sym
      @tok.eat_a '='
      { lhs: lhs, rhs: expr }

    end

    def statements

      while @tok.current != 'EOF'

        case @tok.current

          when 'place'
            place

          when 'transition'
            trans

          when 'wire'
            wire

          else
            if @tok.next == '='
              a = assign
              @metacol.scope.set a[:lhs], @metacol.scope.evaluate( a[:rhs] )
            else  
              raise "Could not find a statement to parse at #{@tok.current}"
            end

        end

      end

    end

  end

end
