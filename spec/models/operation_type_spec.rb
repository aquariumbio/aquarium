# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperationType, type: :model do
  let!(:test_user) { create(:user) }
  let(:param_protocol) do
    create(
      :operation_type,
      name: 'protocol with parameter',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end; end',
      parameters: [
        { name: 'string_param', type: 'string', choices: 'one,two'},
        { name: 'number_param', type: 'number', choices: '1.1,2.2,3.3'}
      ],
      user: test_user
    )
  end
  let(:no_param_protocol) do
    create(
      :operation_type,
      name: 'protocol without parameter',
      category: 'testing',
      protocol: 'class Protocol; def main; show { title \'blah\' }; end; end',
      user: test_user
    )
  end

  context 'parameters' do
    it 'param protocol has fields for parameters' do
      types = param_protocol.field_types
      expect(types).not_to be_empty
      string_type = types.find_by_name('string_param')
      expect(string_type).not_to be_nil
      number_type = types.find_by_name('number_param')
      expect(number_type).not_to be_nil
    end

    it 'no param protocol should not have fields for parameters until updated' do
      no_param_protocol.field_types
      expect(no_param_protocol.field_types).to be_empty
      no_param_protocol.update_field_types([
        { name: 'string_param', ftype: 'string', choices: 'one,two'},
        { name: 'number_param', ftype: 'number', choices: '1.1,2.2,3.3'}
      ])
      types = no_param_protocol.field_types
      expect(types).not_to be_empty
      string_type = types.find_by_name('string_param')
      expect(string_type).not_to be_nil
      expect(string_type.choices).to eq('one,two')
      number_type = types.find_by_name('number_param')
      expect(number_type).not_to be_nil
      expect(number_type.choices).to eq('1.1,2.2,3.3')
    end
  end

end