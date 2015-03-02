require_relative "testlib"
require 'securerandom'

########################################################################################
Test.verify( "Get an error if sample type does not exist --> ", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "create",
      args: {
        model: "sample",
        type: "Primera"
      }
    }
  }) do |response| 
    response[:result] == "error"
end

########################################################################################
name = "Test" + SecureRandom.hex(4)

Test.verify( "Get an error if property does not exist", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "create",
      args: {
        model: "sample",
        type: "Primer",
        name: name,
        project: "Test",
        description: "This is a test of the create api method",
        fields: {
          "Overhung Sequence" => "atccaggactaggacta"
        }
      }
    }
  },loud:true) do |response| 
    response[:result] == "error"
end

########################################################################################
name = "Test" + SecureRandom.hex(4)

Test.verify( "Create a sample named #{name}", { 
    login: Test.login,
    key: Test.key,
    run: {
      method: "create",
      args: {
        model: "sample",
        type: "Primer",
        name: name,
        project: "Test",
        description: "This is a test of the create api method",
        fields: {
          "Overhang Sequence" => "atccaggactaggacta",
          "Anneal Sequence" => "atctcggctatatcgac",
          "T Anneal" => 67.8
        }
      }
    }
  }) do |response| 
    puts " --> New sample has id #{response[:rows][0][:id]}"
    response[:rows][0][:name] = name
end

