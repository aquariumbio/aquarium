require_relative 'testlib'
require 'securerandom'

fwd = 'Fwd' + SecureRandom.hex(4)
rev = 'Rev' + SecureRandom.hex(4)
template = 'pGFP'
frag = 'Frag' + SecureRandom.hex(4)

fwd_id = -1
rev_id = -1
frag_id = -1
temp_id = -1

Test.verify("Create a primer named #{fwd}",
            login: Test.login,
            key: Test.key,
            run: {
              method: 'create',
              args: {
                model: 'sample',
                type: 'Primer',
                name: fwd,
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
  fwd_id = response[:rows][0][:id]
  response[:rows][0][:name] == fwd
end

Test.verify("Create a primer named #{rev}",
            login: Test.login,
            key: Test.key,
            run: {
              method: 'create',
              args: {
                model: 'sample',
                type: 'Primer',
                name: rev,
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
  rev_id = response[:rows][0][:id]
  response[:rows][0][:name] == rev
end

Test.verify('Find pGFP', {
              login: Test.login,
              key: Test.key,
              run: {
                method: 'find',
                args: {
                  model: :sample,
                  where: { name: template }
                }
              }
            }, loud: true) do |response|
  puts "Found #{response[:rows][0][:id]}"
  temp_id = response[:rows][0][:id]
  response[:rows].length == 1
end

Test.verify("Create a fragment named #{frag}",
            login: Test.login,
            key: Test.key,
            run: {
              method: 'create',
              args: {
                model: 'sample',
                type: 'Fragment',
                name: frag,
                project: 'Test',
                description: 'This is a test of the create api method',
                fields: {
                  'Sequence' => 'N/A',
                  'Length' => 3000,
                  'Template' => temp_id,
                  'Forward Primer' => fwd_id,
                  'Reverse Primer' => rev,
                  'Restriction Enzyme(s)' => 'N/A'
                }
              }
            }) do |response|
  puts " --> New sample has id #{response[:rows][0][:id]}"
  frag_id = response[:rows][0][:id]
  response[:rows][0][:name] == frag
end
