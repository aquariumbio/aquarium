# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'announcements/edit', type: :view do
  before(:each) do
    @announcement = assign(:announcement, Announcement.create!(
                                            message: 'MyText',
                                            active: false
                                          ))
  end

  it 'renders the edit announcement form' do
    render

    assert_select 'form[action=?][method=?]', announcement_path(@announcement), 'post' do

      assert_select 'textarea#announcement_message[name=?]', 'announcement[message]'

      assert_select 'input#announcement_active[name=?]', 'announcement[active]'
    end
  end
end
