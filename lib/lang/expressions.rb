module Lang

  class Parser

     def add_function name, num_args
       if !@functions
         @functions = {}
       end
       @functions[name] = num_args
     end

     def array_expr ###################################################################################

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

     def hash_expr ####################################################################################
     
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

     def app ##########################################################################################

       name = @tok.current
       
       if @functions && @functions[name.to_sym]
         name = @tok.eat_a_variable
         e = name
         e += @tok.eat_a '('
           (1..@functions[name.to_sym]).each do |i|
             e += expr
             if i < @functions[name.to_sym]
               e += @tok.eat_a ','
             end
           end
         e += @tok.eat_a ')'
       elsif @function_callback
         e = @function_callback.call
       else
         raise "No function names defined at #{@tok}"
       end

       return e

     end

     def primary ######################################################################################

       case @tok.current

         when @tok.string
           f = @tok.eat

         when @tok.boolean 
           f = @tok.eat

         when @tok.variable
           if @tok.next == '('
             f = app
           else
             f = '%{' + @tok.eat + '}'
           end

         when @tok.number
           f = @tok.eat

         when '('
           @tok.eat
           f = '(' + expr + ')'
           @tok.eat_a ')'

         when '['
            f = array_expr
 
         when '{'
            f = hash_expr

         else
           @tok.error "Expected atomic expression at '#{@tok.current}'."

       end

       return f

     end # primary

     def accessor ######################################################################################

       f = primary

       while @tok.current == '['
         @tok.eat_a '['
         f += '[' + index + ']'
         @tok.eat_a ']'
       end

       return f

     end # accessor

     def index #########################################################################################
 
       if @tok.current == ':' 
         @tok.eat_a ':'
         f = ':' + @tok.eat_a_variable
       else
         f = expr
       end

       return f

     end # index

     def unary #########################################################################################

       if @tok.current == '!' || @tok.current == '-'
         f = (@tok.eat) + accessor
       else
         f = accessor
       end

       return f

     end # unary

     def expr ###########################################################################################

       e = unary

       while @tok.isa_operator
         # puts "eating operator"
         e += @tok.eat
         e += unary
       end

       return e

     end

  end

end
