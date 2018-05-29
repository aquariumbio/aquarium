# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'parameters/edit', type: :view do
  before(:each) do
    @parameter = assign(:parameter, Parameter.create!(
                                      key: '',
                                      value: 'MyString'
                                    ))
  end

  it 'renders the edit parameter form' do
    render

    assert_select 'form[action=?][method=?]', parameter_path(@parameter), 'post' do

      assert_select 'input#parameter_key[name=?]', 'parameter[key]'

      assert_select 'input#parameter_value[name=?]', 'parameter[value]'
    end
  end
end
