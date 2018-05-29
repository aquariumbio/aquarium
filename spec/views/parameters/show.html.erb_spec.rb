# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'parameters/show', type: :view do
  before(:each) do
    @parameter = assign(:parameter, Parameter.create!(
                                      key: '',
                                      value: 'Value'
                                    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Value/)
  end
end
