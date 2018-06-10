

require_relative 'testlib'

#####################################################################################
Test.verify('Get all krill jobs',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: 'job'
              }
            }) do |response|
  puts "Got #{response[:rows].length} rows"
  !response[:error]
end

puts
