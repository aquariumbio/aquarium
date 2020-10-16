# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    state { [{ "operation": 'initialize', "arguments": { "time": '2020-01-01T00:00:00Z' } }] }
  end
end
