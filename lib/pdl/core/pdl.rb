puts "#{File.dirname(__FILE__)}"

require_relative 'protocol'
require_relative 'scope'
require_relative 'interpreter'
require_relative 'pdl_item'

Dir["#{File.dirname(__FILE__)}/*instruction.rb"].each { |file| require file }

require_relative 'viewer'

