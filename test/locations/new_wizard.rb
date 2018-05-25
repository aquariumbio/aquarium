require_relative 'testlib'

begin
  puts 'Create, test and destroy a wizard'

  puts '  Creating wizard'
  wiz = generic_wizard 16, 81
  puts "    id = #{wiz.id}"

  puts '  Testing basic methods'
  puts '    limit = ' + wiz.limit.to_s
  puts '    caps = ' + wiz.caps.to_s

  puts '  Destroying Wizard'
  wiz.destroy
  pass
rescue Exception => e
  puts e.to_s
  raise
end
