require 'time'

class LogInstruction < Instruction

  attr_reader :type, :data, :log_file

  def initialize type, data, log_file, options = {}

    super 'log', options
    @type = type
    @data = data

    # TERMINAL
    @log_file = log_file

  end

  # RAILS ###################################################################################################

  def bt_execute scope, params

    data_value = scope.evaluate @data

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = @type
    log.data = data_value.to_json
    log.save

  end

  # TERMINAL ###############################################################################################

  def execute scope
    # log_str = "Log: " + @type.to_s + " at time " + Time.now.to_s
    log_str = @type.to_s + "\t" + (scope.substitute @data).to_s + "\n"
    # log_file = File.open(@log_path, "w")
    @log_file.puts(Time.now.to_s + "\t" + log_str)
    # log_file.close
  end

end
