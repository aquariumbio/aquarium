require 'time'

class LogInstruction < Instruction

  attr_reader :type, :data, :log_file

  def initialize type, data, log_file
    super 'log'
    @type = type
    @data = data
    @log_file = log_file
  end

  def execute scope
    #log_str = "Log: " + @type.to_s + " at time " + Time.now.to_s
    log_str = @type.to_s + "\t" + (scope.substitute @data).to_s + "\n" 
    #log_file = File.open(@log_path, "w")
    @log_file.puts(Time.now.to_s + "\t" + log_str)
    #log_file.close
  end

end
