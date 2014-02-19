module Plankton

  class ReturnInstruction < Instruction

    def initialize ret_expr, options = {}
      @destination = 0
      @ret_expr = ret_expr
      super 'return', options
    end

    def bt_execute scope, params

      retvals = scope.get :__RETVALS__
      fid = scope.get :__FUNCTION_CALL_ID__

      if !retvals[fid]
        retvals[fid] = []
      end
 
      puts "About to evaluate #{@ret_expr}"

      rval = scope.evaluate @ret_expr 
      retvals[fid].push rval
      scope.set :__RETVALS__, retvals

      puts "  Returning #{@ret_expr} = #{rval} from #{fid}. Scope is now #{scope.inspect} (before double pop)."

      @destination = scope.get :__RETURN_PC__

      # pop local variables and any other scopes (e.g. if return statement is in an if or while
      while ! scope.defined_in_top :__FUNCTION_CALL_ID__
        scope.pop
      end

      # pop arguments
      scope.pop

      puts "    After popping, scope is #{scope.inspect} (before double pop)."

      puts "Will return to #{@destination}"

    end

    def set_pc scope
      @destination
    end
 
  end

end
