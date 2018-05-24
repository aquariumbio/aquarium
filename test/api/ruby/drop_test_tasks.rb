require_relative 'testlib'

tasks = [2466, 2465, 2464, 2463, 2444, 2443, 2443, 2441, 2440]

Test.verify("Drop Test samples", {
              login: Test.login,
              key: Test.key,
              run: {
                method: "drop",
                args: {
                  model: "task",
                  ids: tasks
                }
              }
            }) do |response|
  puts " --> warnings: '#{response[:warnings].join(', ')}'"
  response[:warnings].length == 0
end
