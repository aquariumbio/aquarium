# frozen_string_literal: true

require_relative 'testlib'

###################################################################################
Test.verify('Successful login',
            login: Test.login,
            key: Test.key) do |response|
  response[:result] == 'ok'
end

###################################################################################
Test.verify('Unsuccessful login',
            login: Test.login,
            key: 'open seseame') do |response|
  response[:result] != 'ok'
end
