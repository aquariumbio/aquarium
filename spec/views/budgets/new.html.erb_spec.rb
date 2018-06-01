

require 'rails_helper'

RSpec.describe 'budgets/new', type: :view do
  before(:each) do
    assign(:budget, Budget.new)
  end

  it 'renders new budget form' do
    render

    assert_select 'form[action=?][method=?]', budgets_path, 'post' do
    end
  end
end
