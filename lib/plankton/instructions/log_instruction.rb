require 'time'

module Plankton

  class LogInstruction < Instruction

    attr_reader :type, :data, :log_file

    def initialize(type, data, log_file, options = {})

      super 'log', options
      @type = type
      @data = data

      # TERMINAL
      @log_file = log_file

    end

    # RAILS ###################################################################################################

    def bt_execute(scope, params)

      data_value = scope.evaluate @data

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = @type
      log.data = data_value.to_json
      log.save

    end

  end

end
