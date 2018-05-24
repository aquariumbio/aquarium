require_relative "testlib"
require 'securerandom'

tpid = 0

########################################################################################
Test.verify("Get task prototype for Gibson Assembly --> ", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "find",
                args: {
                  model: "task_prototype",
                  where: { name: "Gibson Assembly" }
                }
              }
            }, loud: true) do |response|
  tpid = response[:rows][0][:id]
  puts "Gibson Assembly ID: #{tpid}"
  response[:result] != "error"
end

name = "Test" + SecureRandom.hex(4)

########################################################################################
Test.verify("Get an error if task status not valid --> ", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "create",
                args: {
                  model: "task",
                  name: name,
                  status: "wooting",
                  task_prototype_id: tpid,
                  specification: {}
                }
              }
            }) do |response|
  response[:result] == "error"
end

########################################################################################
Test.verify("Get an error if specification is not valid --> ", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "create",
                args: {
                  model: "task",
                  name: name,
                  status: "waiting",
                  task_prototype_id: tpid,
                  specification: {
                    ploosmid: 2,
                    fragments: [5636, 5637, 5638]
                  }
                }
              }
            }) do |response|
  response[:result] == "error"
end

########################################################################################
Test.verify("Make a task--> ", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "create",
                args: {
                  model: "task",
                  name: name,
                  status: "waiting",
                  task_prototype_id: tpid,
                  specification: {
                    "plasmid Plasmid" => 2,
                    "fragments Fragment" => [5636, 5637, 5638]
                  }
                }
              }
            }, loud: true) do |response|
  response[:result] != "error"
end

# TODO: MODIFY Task

# TODO: DROP Task
