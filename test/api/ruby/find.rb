require_relative 'testlib'

###################################################################################

[ [:item,123], [:job,5000], [:sample,123], 
  [:sampletype,12], [:objecttype,100], [:user,20], 
  [:task,14] ].each do |thing,id|

  Test.verify( "Find #{thing}", { 
      login: Test.login,
      key: Test.key,
      run: {
        method: "find",
        args: {
          model: thing,
          where: { id: id }
        }
      }
    }) do |response| 
      response[:result] == "ok"           \
      && response[:rows]                  \
      && response[:rows].length == 1      \
      && response[:rows][0][:id] == id
  end

end

puts 

Test.verify( "Find all users", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "find",
      args: {
        model: :user
      }
    }
  }) do |response| 
    puts " --> " + (response[:rows].collect { |r| 
      return false unless r[:login]
      r[:login]
    }).join(", ")
    true
end
  
puts

#####################################################################################
Test.verify( "Get a job backtrace", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "find",
      args: {
        model: :job,
        where: { id: 5000 }
      }
    }
  }) do |response| 
    bt = response[:rows][0][:backtrace]
    puts " --> #{bt}"
    bt ? true : false
end

puts

########################################################################################
Test.verify( "Get all items assocated with a sample", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "find",
      args: {
        model: :item,
        where: { sample: { name: "CFP_r" } },
        includes: :sample
      }
    }
  }) do |response| 
    puts " --> " + (response[:rows].collect { |r| 
      return false unless r[:id]
      r[:id]
    }).join(", ")
    true
end

puts

########################################################################################
Test.verify( "Get 32 items", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "find",
      args: {
        model: :item,
        limit: 32
      }
    }
  }) do |response| 
    response[:rows].length == 32
end
