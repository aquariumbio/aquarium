require 'CSV'

def new_user_id x
  y = 0
  CSV.foreach('/Users/ericklavins/Development/bioturk/lib/port/user.csv',"r") do |row|
    if row[0].to_i == x
      y = row[3].to_i
    end
  end
  y
end
