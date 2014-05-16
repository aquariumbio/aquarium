module Oyster

  class Parser < Lang::Parser

    def initialize path, contents
      @tok = Lang::Tokenizer.new contents 
      @metacol = Metacol.new
      @path = path
      @default_repo = path.split('/')[0]
      functions
      time_functions
      super() # adds array, string, collection, sample functions
    end   

    def functions
      add_function :completed, 1
      add_function :error, 1
      add_function :return_value, 2
      add_function :hours_elapsed, 2
      add_function :minutes_elapsed, 2
    end

    def parse args = {}
      @metacol.set_args args
      statements
      @metacol
    end

    def statements

      while @tok.current != 'EOF'

        case @tok.current

          when 'argument'
            arguments

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

    end # statements

    def parse_arguments_only

      while @tok.current != 'EOF'

        while @tok.current != 'EOF' && @tok.current != 'argument' && @tok.current != 'place'
          @tok.eat
        end

        if @tok.current == 'place'
          while @tok.current != 'EOF'
            @tok.eat
          end
        end

        if @tok.current == 'argument'
          arguments
        end

      end

      @metacol.arguments

    end # arguments_only


  end

end
