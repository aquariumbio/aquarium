class Instruction
 
  attr_reader :name

  def initialize name
    @name = name
  end

  def clear
    puts "\e[2J\e[f"
  end

  def liaison verb, args
    uri = URI("http://bioturk.ee.washington.edu:3000/liaison/#{verb}.json")
    uri.query = URI.encode_www_form(args)
    result = Net::HTTP.get_response(uri)
    JSON.parse(result.body, {:symbolize_names => true})
  end

  def to_s
    @name + "\n  " + ( instance_variables.map { |i| "#{i}: " + (instance_variable_get i).to_s } ).join("\n  ")
  end

end

