module Lang

  class Parser

     def initialize ###################################################################################

      # Numerical functions
      add_function :floor, 1
      add_function :ceil, 1
      add_function :sqrt, 1
      add_function :log, 1
      add_function :log2, 1
      add_function :log10, 1
      add_function :random, 1
      add_function :min, 2
      add_function :max, 2
      add_function :cos, 1
      add_function :sin, 1
      add_function :tan, 1
      add_function :acos, 1
      add_function :asin, 1
      add_function :atan, 1
      add_function :atan2, 2

      # Array functions
      add_function :length, 1
      add_function :append, 2
      add_function :concat, 2
      add_function :unique, 1

      # Hash functions
      add_function :merge, 2
      add_function :keys, 1
      add_function :delete, 2
      add_function :key, 2

      # String functions
      add_function :to_string, 1
      
      # Collection functions
      add_function :collection, 1

      # Sample functions
      add_function :info, 1

     end

     def add_function name, num_args ##################################################################
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

         when ':'
           f = @tok.eat + @tok.eat_a_variable

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

     end # expr

     def get_lhs_parts ####################################################################################

       begin

         v = @tok.eat_a_variable
         f = ""

         while @tok.current == '['
           @tok.eat_a '['
           f += '[' + index + ']'
           @tok.eat_a ']'
         end

       rescue Exception => e

         raise "Expression is not a proper left hand side for an assignment: " + e.to_s

       end       

       return { var: v.to_sym, accessor: f }

     end # is_lhs

  end

end
