require 'rails_helper'

RSpec.describe Announcement, type: :model do
  context "basics" do
    it "gets some announcements" do
      Announcement.last(5).reverse
    end
  end
end
