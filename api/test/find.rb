require_relative 'testlib'

###################################################################################

[ ["item",123], ["job",5000], ["sample",123], 
  ["sampletype",12], ["objecttype",100], ["user",20], 
  ["task",14] ].each do |thing,id|

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
        model: "user"
      }
    }
  }) do |response| 
    p = true
    begin
      puts " --> " + (response[:rows].collect { |r| r[:login] }).join(", ")
    rescue
      p = false
    end
    p   
  end
  
puts

Test.verify( "Get job backtrace", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "find",
      args: {
        model: "job",
        where: { id: 5000 }
      }
    }
  }) do |response| 
    p = true
    begin
      puts " --> #{(response[:rows][0][:backtrace])}"
    rescue
      p = false
    end
    p     
  end


