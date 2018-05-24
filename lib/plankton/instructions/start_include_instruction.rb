module Plankton

  class StartIncludeInstruction < Instruction

    attr_reader :arguments, :filename

    def initialize args, file, sha, options = {}
      super 'start_include', options
      @arguments = args
      @filename = file
      @renderable = false
      @sha = sha
    end

    def bt_execute scope, params

      # push a new scope so we don't overwrite the variables in the including file
      scope.push

      # take the evaluated args and push then onto the scope
      @arguments.each do |var, expr|
        begin
          scope.set var.to_sym, scope.evaluate(expr)
        rescue Exception => e
          raise "Could not evaluate '#{expr}' in include statement."
        end
      end

      # log the result
      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'INCLUDE'
      log.data = { pc: @pc, file: @filename, sha: @sha }.to_json
      log.save

    end

    def html
      h = "<b>start include</b> #{@filename}, <b>args</b>: "
      @arguments.each do |var, expr|
        h += "#{var} = #{expr}, "
      end
      return h[0..-3]
    end

    def to_html
      "start include " + @filename
    end

  end

end
