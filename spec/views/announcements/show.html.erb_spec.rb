# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'announcements/show', type: :view do
  before(:each) do
    @announcement = assign(:announcement, Announcement.create!(
                                            message: 'MyText',
                                            active: false
                                          ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
  end
end
