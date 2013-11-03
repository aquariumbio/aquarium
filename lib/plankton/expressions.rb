module Plankton

  class Parser

     def array_expr

       e = @tok.eat_a '['
       while @tok.current != ']'
         e += expr
         if @tok.current == ','
           e += @tok.eat_a ','
         end
       end
       e += @tok.eat_a ']'
       return e

     end

     def hash_expr
     
       e = @tok.eat_a '{'
    
       while @tok.current != '}'

         e += @tok.eat_a_variable
         e += @tok.eat_a ':'
         e += expr
         if @tok.current == ','
           e += @tok.eat_a ','
         end

       end

       e += @tok.eat_a '}'

       return e

     end

     def factor

       case @tok.current

         when @tok.number
           f = @tok.eat

         when @tok.string
           f = @tok.eat

         when @tok.boolean 
           f = @tok.eat

         when @tok.variable
           f = '%{' + @tok.eat + '}'

         when '('
           @tok.eat
           f = expr
           @tok.eat_a ')'

         when '['
            f = array_expr
 
         when '{'
            f = hash_expr

         else
           raise "Expected atomic expression at #{@tok.current}"

       end

       return f

     end

     def expr

       e = ""

       if @tok.current == '-' || @tok.current == '+'
         e += @tok.eat
       end

       e += factor

       while @tok.is_operator
         e += @tok.eat
         e += factor
       end

       return e

     end

  end

end
