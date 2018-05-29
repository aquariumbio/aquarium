# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'budgets/edit', type: :view do
  before(:each) do
    @budget = assign(:budget, Budget.create!)
  end

  it 'renders the edit budget form' do
    render

    assert_select 'form[action=?][method=?]', budget_path(@budget), 'post' do
    end
  end
end
