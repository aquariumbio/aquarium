# frozen_string_literal: true

FactoryBot.define do
  factory :operation_type do
    transient do
      protocol {}
      cost_model { 'def cost(_op); { labor: 0, materials: 0 } end' }
      precondition { 'def precondition(_op); true end' }
      test { 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end;' }
      user {}
      inputs { [] }
      outputs { [] }
    end

    sequence(:name) { |n| "operation_type_#{n}" }
    category { 'the category' }
    deployed { true }
    initialize_with { OperationType.where(name: name, category: category).first_or_create }

    after(:create) do |operation_type, evaluator|
      if evaluator.protocol && evaluator.user
        operation_type.add_protocol(content: evaluator.protocol, user: evaluator.user)
        operation_type.add_cost_model(content: evaluator.cost_model, user: evaluator.user)
        operation_type.add_precondition(content: evaluator.precondition, user: evaluator.user)
        operation_type.add_test(content: evaluator.test, user: evaluator.user)

        evaluator.inputs.each do |input|
          operation_type.add_input(input[:name], input[:sample_type], input[:object_type])
        end
        evaluator.outputs.each do |output|
          operation_type.add_output(output[:name], output[:sample_type], output[:object_type])
        end
      end
    end
  end
end
