module Lang

  class Tokenizer

    attr_reader :line

    def initialize str 

      @str = str
      @tokens = str.scan(re).reject { |t| comment.match t }
      @i = -1
      @line = 0

      advance

      #i=0
      #while i<@tokens.length
      #  if /^\n|^\r/.match(@tokens[i])
      #    puts "#{i}: \\n"
      #  else
      #    puts "#{i}: #{@tokens[i]}"
      #  end
      #  i += 1
      #end
      #puts '-----------'

    end

    def num_newlines t
      t.scan(/\n|\r/).length
    end

    def advance

      @line += num_newlines( @tokens[@i] )
      @i=@i+1

      while /^\s$/.match( @tokens[@i] )
        if /\n|\r/.match( @tokens[@i] )
          @line += 1
        end
        @i = @i+1
      end

    end

    def current
      if @i < @tokens.length
        return @tokens[@i]
      else
        return 'EOF'
      end
    end

    def next

      j=@i+1

      while j < @tokens.length && /^\s$/.match( @tokens[j] )
        j=j+1
      end
      
      if j < @tokens.length
        return @tokens[j]
      else
        return 'EOF'
      end

    end

    def eat
      t = current
      #puts '--> ' + t
      advance
      return t
    end

    def eat_a thing
      if current != thing
        error "Expected '#{thing}' at '#{@tokens[@i]}'."
      else
        return eat
      end
    end

    def get_line

      j = @i
      k = @i

      while j >= 0 && ! /\n|\r/.match(@tokens[j])
        j -= 1
      end

      while k < @tokens.length && ! /\n|\r/.match(@tokens[k])
        k += 1
      end

      @line_elements = @tokens[j+1,k-j-1]
      @line_elements[@i-j-1] = "<span style='font-weight: bold; color: red'>" + @line_elements[@i-j-1].to_s + "</span>"
      @line_elements.join

    end

    def error msg
      raise "Parse error on line #{@line}. " + msg
    end

    ####################################################################
    # Regexps

    def whitespace
      /\s/
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

    def isa_operator
      /^(\+|-|\/|\*\*|\*|<=|>=|<|>|==|!=|\|\||&&|!)$/.match(self.current) != nil
    end

    def trans_op
      /=>/
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
      /#[^#\n\r]*/
    end

    def number
      /[0-9]+\.[0-9]*|[0-9]*\.[0-9]+|[0-9]+/
    end

    def junk
      /@|&|\|/
    end

    checker :string, :whitespace, :variable, :argtype, :take_ops, :trans_op, :operator, :equals, :punctuation, :number, :boolean, :junk, :comment

    # utilities   
    def positive_integer
      /^[1-9][0-9]*$/.match current
    end


  end

end





