# frozen_string_literal: true

require_relative 'testlib'
require 'securerandom'

(1..10).each do |_i|

  name = 'Test' + SecureRandom.hex(4)

  Test.verify("Create a sample named #{name}",
              login: Test.login,
              key: Test.key,
              run: {
                method: 'create',
                args: {
                  model: 'sample',
                  type: 'Primer',
                  name: name,
                  project: 'Test',
                  description: 'This is a test of the create api method',
                  fields: {
                    'Overhang Sequence' => 'atccaggactaggacta',
                    'Anneal Sequence' => 'atctcggctatatcgac',
                    'T Anneal' => 67.8
                  }
                }
              }) do |response|
    puts " --> New sample has id #{response[:rows][0][:id]}"
    response[:rows][0][:name] = name
  end

end

########################################################################################

samples = []

Test.verify('Find all Test samples', {
              login: Test.login,
              key: Test.key,
              run: {
                method: 'find',
                args: {
                  model: :sample,
                  where: { project: 'Test' }
                }
              }
            }, loud: false) do |response|
  samples = response[:rows].collect { |r| r[:id] }
  puts ' --> ' + samples.to_s
  true
end

Test.verify('Drop Test samples',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'drop',
              args: {
                model: 'sample',
                ids: samples
              }
            }) do |response|
  puts " --> warnings: '#{response[:warnings].join(', ')}'"
  response[:warnings].empty?
end
