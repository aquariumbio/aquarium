names = [
  ["Borgman", "Joshua"], 
  ["Chavali", "Venkata"], 
  ["Hassanzadah", "Pegah"], 
  ["Jain", "Sonal"], 
  ["Lavania", "Chandashekhar"], 
  ["Ma", "Patrick"], 
  ["Newton", "Michael"], 
  ["Pollard", "Timothy"], 
  ["Xiao", "Sa"], 
  ["Baryshev", "Alexander"], 
  ["Josberger", "Erik"], 
  ["Kim", "Bonghoe"], 
  ["Nelson", "Gregory"], 
  ["Rollins", "Nathanael"], 
  ["Startebaum", "David"]
]

names.each do |name|

  #u = User.new
  #u.login = name[0].downcase
  #u.name = "#{name[1]} #{name[0]}"
  #u.password = "aqua#{name[0].downcase}"
  #u.password_confirmation = "aqua#{name[0].downcase}"
  #u.save

  login = name[0].downcase
  u = User.find_by_login(login)
  g = Group.new
  g.name = login
  g.description = "A group containing only user #{login}"
  g.save

end 

