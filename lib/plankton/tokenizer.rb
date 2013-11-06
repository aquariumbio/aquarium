module Plankton

  class Tokenizer

    def initialize str 

      @str = str
      @tokens = str.scan(re).reject { |t| comment.match t }
      @i = 0
      #puts @tokens
      #puts '-----------'

    end

    def current
      if @i < @tokens.length
        return @tokens[@i]
      else
        return 'EOF'
      end
    end

    def next
      if @i+1 < @tokens.length
        return @tokens[@i+1]
      else
        return 'EOF'
      end
    end

    def eat
      t = current
      puts '--> ' + t
      @i += 1
      return t
    end

    def eat_a thing
      if current != thing
        raise "Expected '#{thing}' at '#{@tokens[@i]}'."
      else
        return eat
      end
    end

    ####################################################################
    # Regexps

    def keyword
      /argument|end|step|description|note|warning|getdata|select|take|produce|data|release|if|else|elsif/
    end

    def boolean
       /true|false/
    end

    def argtype 
      /number|string|object|sample/ 
    end

    def variable
      /[a-zA-Z_][a-zA-Z_0-9]*/
    end

    def string 
      /"[^"]*"/ 
    end

    def operator  
      /\+|-|\/|\*\*|\*|<=|>=|<|>|==|!=|\|\||&&|!/
    end

    def take_ops
      /<-/
    end

    def equals
      /=/
    end

    def punctuation
      /:|,|\(|\)|\[|\]|\}|\{/
    end

    def comment
      /#.*/
    end

    def number
      /[0-9]+\.[0-9]*|[0-9]*\.[0-9]+|[0-9]+/
    end

    checker :string, :variable, :keyword, :argtype, :take_ops, :operator, :equals, :punctuation, :comment, :number, :boolean

    # unilities   
    def positive_integer
      /^[1-9][0-9]*$/.match current
    end


  end

end





