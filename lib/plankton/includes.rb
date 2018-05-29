# frozen_string_literal: true

module Plankton

  class Parser

    def include

      lines = {}
      lines[:startline] = @tok.line

      if @tok.current == 'require'
        @tok.eat_a 'require'
        req = true
      else
        @tok.eat_a 'include'
        req = false
      end

      path = @tok.eat_a_string.remove_quotes

      args = {}
      rets = {}

      unless req # this is an include statement, not a require statement, so there may be arguments

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

        @tok.eat_a 'end'

      end

      lines[:endline] = @tok.line

      file = get_file path

      @tok = Lang::Tokenizer.new file[:content]
      @include_stack.push(tokens: @tok, path: path, returns: rets)

      push StartIncludeInstruction.new args, path, file[:sha], lines

    end # include

  end

end
