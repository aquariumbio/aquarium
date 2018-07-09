

require 'rails_helper'

RSpec.describe 'parameters/new', type: :view do
  before(:each) do
    assign(:parameter, Parameter.new(
                         key: '',
                         value: 'MyString'
                       ))
  end

  it 'renders new parameter form' do
    render

    assert_select 'form[action=?][method=?]', parameters_path, 'post' do

      assert_select 'input#parameter_key[name=?]', 'parameter[key]'

      assert_select 'input#parameter_value[name=?]', 'parameter[value]'
    end
  end
end
