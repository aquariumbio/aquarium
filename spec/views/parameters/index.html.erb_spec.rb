require 'rails_helper'

RSpec.describe 'parameters/index', type: :view do
  before(:each) do
    assign(:parameters, [
             Parameter.create!(
               key: '',
               value: 'Value'
             ),
             Parameter.create!(
               key: '',
               value: 'Value'
             )
           ])
  end

  it 'renders a list of parameters' do
    render
    assert_select 'tr>td', text: ''.to_s, count: 2
    assert_select 'tr>td', text: 'Value'.to_s, count: 2
  end
end
