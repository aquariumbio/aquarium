# frozen_string_literal: true

require 'csv'

def new_user_id(x)
  y = 0
  CSV.foreach('/var/rails/btor_test/lib/port/user.csv', 'r') do |row|
    y = row[3].to_i if row[0].to_i == x
  end
  y
end
