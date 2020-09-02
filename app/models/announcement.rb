# typed: false
# frozen_string_literal: true

class Announcement < ApplicationRecord
  attr_accessible :active, :title, :message
end
