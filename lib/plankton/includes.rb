module Plankton

  class Parser

    def include

      lines = {}
      lines[:startline] = @tok.line

      @tok.eat_a 'include'
      path = @tok.eat_a_string.remove_quotes

      args = {}
      rets = {}

      while @tok.current != 'end' && @tok.current != 'EOF'

        if @tok.next == ':'

          a = @tok.eat_a_variable
          @tok.eat_a ':'
          args[a] = expr

        elsif @tok.next == '='

          r = @tok.eat_a_variable
          @tok.eat_a '='
          rets[r] = expr

        else
          raise "Unknown element in include statement at '#{@tok.current}'."
        end

      end

      lines[:endline] = @tok.line
      @tok.eat_a 'end'

      file = get_file path


      @tok = Lang::Tokenizer.new file[:content]
      @include_stack.push( { tokens: @tok, path: path, returns: rets } )

      #puts "Just before beginning included file, current = #{@tok.current}"

      push StartIncludeInstruction.new args, path, file[:sha], lines

    end # include

  end

end
