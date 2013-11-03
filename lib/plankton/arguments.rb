module Plankton

  class Parser

    def initialize str
      @tok = Tokenizer.new ( str )
    end

    def argument
  
      var =  @tok.eat_a_variable
             @tok.eat_a ':'
      type = @tok.eat_a_argtype

      if @tok.current == ','
        @tok.eat
        comment = @tok.eat_a_string.remove_quotes
      else
        comment = ""
      end

      puts "ARG: #{var} : #{type}, #{comment}"

    end # argument

    def argument_list
      
      @tok.eat_a 'argument'
      while @tok.current != 'end'
        argument
      end
      @tok.eat_a 'end'

      return true

    end # argument_list

  end

end
