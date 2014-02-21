module Plankton

  class InputInstruction < Instruction

    def initialize v, filename_expr, options = {}
      @var = v
      @filename_expr = filename_expr
      @renderable = false
      super 'input', options
    end

    def bt_execute scope, params

      filename = scope.evaluate @filename_expr
      begin
        b = Blob.get_file(-1,filename)
      rescue Exception => e
        raise "Could not find input file #{@filename_expr}." + e.to_s
      end
      j = JSON.parse(b[:content], symbolize_names: true)
      scope.set @var.to_sym, j

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'INPUT'
      log.data = { var: @var, filename: filename, sha: b[:sha] }.to_json
      log.save

    end

  end

end
