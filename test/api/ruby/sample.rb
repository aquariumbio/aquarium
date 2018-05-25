require_relative "testlib"
require 'securerandom'

########################################################################################
name = "Test" + SecureRandom.hex(4)

Test.verify("Get an error if property does not exist", {
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
            }, loud: true) do |response|
  response[:result] == "error"
end

########################################################################################
name = "Test" + SecureRandom.hex(4)

Test.verify("Create a sample named #{name}", {
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
  response[:rows][0][:name] == name
end

Test.verify("Get an error if the sample name is already in use", {
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
  response[:result] == "error"
end

Test.verify("Drop the sample named #{name}", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "drop",
                args: {
                  model: "sample",
                  names: [name]
                }
              }
            }) do |response|
  puts " --> " + response[:warnings].join(', ')
  response[:warnings].length == 0
end
