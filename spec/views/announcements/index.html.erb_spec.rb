

require 'rails_helper'

RSpec.describe 'announcements/index', type: :view do
  before(:each) do
    assign(:announcements, [
             Announcement.create!(
               message: 'MyText',
               active: false
             ),
             Announcement.create!(
               message: 'MyText',
               active: false
             )
           ])
  end

  it 'renders a list of announcements' do
    render
    assert_select 'tr>td', text: 'MyText'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
