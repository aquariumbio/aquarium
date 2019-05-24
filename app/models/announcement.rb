# frozen_string_literal: true

class Announcement < ActiveRecord::Base
  attr_accessible :active, :title, :message
end
