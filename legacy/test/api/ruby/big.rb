# typed: strict
# frozen_string_literal: true

require_relative 'testlib'

n = 1000

########################################################################################
t1 = Time.now
Test.verify("Get #{n} items",
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: :item,
                limit: n
              }
            }) do |response|
  puts
  puts "Got #{response[:rows].length} rows"
  response[:rows].length == n
end

t2 = Time.now
puts "#{(t2 - t1) * 1000} ms"

########################################################################################
t1 = Time.now
Test.verify('Get all samples',
            login: Test.login,
            key: Test.key,
            run: {
              method: 'find',
              args: {
                model: :sample
              }
            }) do |response|
  puts
  puts "Got #{response[:rows].length} rows"
  response[:result] != 'error'
end

t2 = Time.now
puts "#{(t2 - t1) * 1000} ms"
