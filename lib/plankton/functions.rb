module Plankton

  class Parser

    def function_def ############################################################################

      if @in_function_def
        raise "Functions may only be defined outside all other function definitions."
      end

      @tok.eat_a 'function'
      fname = @tok.eat_a_variable

      @tok.eat_a '('
      args = []
      while @tok.current != ')' and @tok.current != 'EOF'
        args.push @tok.eat_a_variable
        if @tok.current == ','
          @tok.eat_a ','
        end
      end
      @tok.eat_a ')'

      @in_function_def = true
      @function_specs[fname.to_sym] = { pc: pc, arg_names: args, fname: fname }

      statements

      unless last.name == 'return'
        push ReturnInstruction.new "false"
      end

      @in_function_def = false

      @tok.eat_a 'end'

    end # end function_def 

    def return_statement #########################################################################

      if !@in_function_def
        raise "Encountered a return statement outside of a function definition."
      else 
        lines = {}
        lines[:startline] = @tok.line
        @tok.eat_a 'return'
        e = expr
        lines[:endline] = @tok.line
        push ReturnInstruction.new e, lines.merge(new: true)
      end

    end # end return_statement

    def function_call_id
      fid = "fid#{@function_call_num}"
      @function_call_num += 1
      return fid
    end

    def function_call #############################################################################

      lines = {}
      lines[:startline] = @tok.line
      fname = @tok.eat_a_variable

      @tok.eat_a '('
      arg_exprs = []
      while @tok.current != ')' and @tok.current != 'EOF'
        arg_exprs.push expr
        if @tok.current == ','
          @tok.eat_a ','
        end
      end
      @tok.eat_a ')'

      if !@function_specs[fname.to_sym]
        raise "Unknown function '#{fname.to_sym}'"
      end

      if @function_specs[fname.to_sym][:arg_names].length != arg_exprs.length
        raise "Wrong number of arguments to #{fname} (#{arg_exprs.length} instead of #{@function_specs[fname.to_sym][:arg_names].length})"
      end

      fid = function_call_id
      push FunctionCallInstruction.new fid.to_sym, pc+1, @function_specs[fname.to_sym], arg_exprs, lines
      
      lines[:endline] = @tok.line

      return "__function_return_value__(\"#{fid}\")"

    end # function_call
 
    def append_function_space #######################################################################

      push StopInstruction.new

      offset = pc

      @function_space.each do |i|
        if i.respond_to? :adjust_offset
          i.adjust_offset offset
        end
      end

      @function_specs.each do |k,v|
        @function_specs[k][:pc] = v[:pc] + offset
      end

      @program.concat @function_space

    end # append_function_space

  end

end

module Lang

  class Scope 

    def __function_return_value__ fid
       
      # puts "Getting latest return value for fid = #{fid} with scope = #{inspect}"

      retvals = get :__RETVALS__

      if !retvals[fid.to_sym]
        raise "Could not find return value for #{fid} with revals = #{retvals} and scope = #{inspect}"
      end

      rval = retvals[fid.to_sym].pop

      # puts "    Got #{rval}"

      set :__RETVALS__, retvals
      return rval

    end

  end

end
