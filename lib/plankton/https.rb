module Plankton

  class Parser
  
    def http

      info = { 
        host: '',
        port: '80',
        path: '/',
        query: {},
        body: 'body',
        status: 'status'
      } 

      @tok.eat_a 'http'

      while @tok.current != 'end' && @tok.current != 'EOF'

        key = @tok.eat_a_variable.to_sym

        if key == :status || key == :body

          @tok.eat_a ':'
          info[key] = @tok.eat_a_variable

        elsif key != :query

          @tok.eat_a ':'
          info[key] = string_expr

        else

          while @tok.current != 'end' && @tok.current != 'EOF'
            q = @tok.eat_a_variable.to_sym
            @tok.eat_a ':'
            info[:query][key] = string_expr
          end

          @tok.eat_a 'end'

        end

      end

      @tok.eat_a 'end'

      push HTTPInstruction.new info

    end

  end

end
