

require_relative 'testlib'

###################################################################################
Test.verify('Find all samples owned by a particular user', {
              login: Test.login,
              key: Test.key,
              run: {
                method: 'find',
                args: {
                  model: :sample,
                  where: { user_id: 64 }
                }
              }
            }, loud: true) do |response|
  puts "Found #{response[:rows].length}"
  response[:rows].length >= 0
end

puts

###################################################################################
[[:item, 9891], [:job, 5000], [:sample, 123],
 [:sample_type, 12], [:object_type, 100], [:user, 20],
 [:task, 14]].each do |thing, id|

  Test.verify("Find #{thing}", {
                login: Test.login,
                key: Test.key,
                run: {
                  method: 'find',
                  args: {
                    model: thing,
                    where: { id: id }
                  }
                }
              }, loud: true) do |response|
    response[:result] == 'ok'           \
    && response[:rows]                  \
    && response[:rows].length == 1      \
    && response[:rows][0][:id] == id
  end

end

puts

#####################################################################################
Test.verify('Find all users',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: :user
              }
            }) do |response|
  puts ' --> ' + (response[:rows].collect do |r|
    return false unless r[:login]

    r[:login]
  end).join(', ')
  true
end

puts

#####################################################################################
Test.verify('Get a job backtrace',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: :job,
                where: { id: 5001 }
              }
            }) do |response|
  bt = response[:rows][0][:backtrace].collect { |step| step[:operation] }
  puts " --> #{bt}"
  bt ? true : false
end

puts

########################################################################################
Test.verify('Get all items assocated with a sample', {
              login: Test.login,
              key: Test.key,
              run: {
                method: 'find',
                args: {
                  model: :item,
                  where: { sample: { name: 'CFP_r' } },
                  includes: :sample
                }
              }
            }, loud: true) do |response|
  puts ' --> ' + (response[:rows].collect do |r|
    return false unless r[:id]

    r[:id]
  end).join(', ')
  true
end

puts

########################################################################################
Test.verify('Get 32 items',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: :item,
                limit: 32
              }
            }) do |response|
  response[:rows].length == 32
end

puts

Test.verify('Get three particular items', {
              login: Test.login,
              key: Test.key,
              run: {
                method: 'find',
                args: {
                  model: :item,
                  where: { id: [200, 300, 400] }
                }
              }
            }, loud: true) do |response|
  puts
  puts "Got #{response[:rows].length} rows"
  response[:rows].length == 3
end
