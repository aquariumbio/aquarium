require 'rails_helper'

RSpec.describe "announcements/new", :type => :view do
  before(:each) do
    assign(:announcement, Announcement.new(
      :message => "MyText",
      :active => false
    ))
  end

  it "renders new announcement form" do
    render

    assert_select "form[action=?][method=?]", announcements_path, "post" do

      assert_select "textarea#announcement_message[name=?]", "announcement[message]"

      assert_select "input#announcement_active[name=?]", "announcement[active]"
    end
  end
end
