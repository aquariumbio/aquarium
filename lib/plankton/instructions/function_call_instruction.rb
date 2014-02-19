module Plankton

  class FunctionCallInstruction < Instruction

    def initialize fid, return_to, fspec, arg_exprs, options = {}
      @return_to = return_to
      @fspec = fspec
      @arg_exprs = arg_exprs
      @fid = fid
      super 'function_call', options
      #puts "New function call (#{fid}) returning to #{return_to}"
    end

    def bt_execute scope, params

      scope.push

      scope.set_new :__RETURN_PC__, @return_to # used by return_instruction
      scope.set_new :__FUNCTION_CALL_ID__, @fid # used by return_instruction

      (0..@arg_exprs.length-1).each do |i|
        scope.set_new( @fspec[:arg_names][i].to_sym, scope.evaluate( @arg_exprs[i] ) )
      end

      scope.push

      #puts "Starting function call with fid = #{@fid}. Scope is now #{scope.inspect}"

    end

    def adjust_offset o
      super o
      @return_to += o
    end

    def set_pc scope
      @fspec[:pc]
    end

  end

end
