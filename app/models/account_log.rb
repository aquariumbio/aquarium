# typed: false
# frozen_string_literal: true

class AccountLog < ApplicationRecord
  belongs_to :user
  belongs_to :first_row, class_name: 'Account', foreign_key: :row1
  belongs_to :second_row, class_name: 'Account', foreign_key: :row2
  attr_accessible :note, :row1, :row2, :user_id
end
