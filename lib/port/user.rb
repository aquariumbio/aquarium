require 'csv'

def new_user_id x
  y = 0
  CSV.foreach('/var/rails/btor_test/lib/port/user.csv',"r") do |row|
    if row[0].to_i == x
      y = row[3].to_i
    end
  end
  y
end
