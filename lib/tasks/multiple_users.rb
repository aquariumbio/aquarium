

names = [
  %w[Borgman Joshua],
  %w[Chavali Venkata],
  %w[Hassanzadeh Pegah],
  %w[Jain Sonal],
  %w[Lavania Chandashekhar],
  %w[Ma Patrick],
  %w[Newton Michael],
  %w[Pollard Timothy],
  %w[Xiao Sa],
  %w[Baryshev Alexander],
  %w[Josberger Erik],
  %w[Kim Bonghoe],
  %w[Nelson Gregory],
  %w[Rollins Nathanael],
  %w[Starkebaum David]
]

names.each do |name|

  # u = User.new
  # u.login = name[0].downcase
  # u.name = "#{name[1]} #{name[0]}"
  # u.password = "aqua#{name[0].downcase}"
  # u.password_confirmation = "aqua#{name[0].downcase}"
  # u.save

  login = name[0].downcase
  # u = User.find_by_login(login)
  # g = Group.new
  # g.name = login
  # g.description = "A group containing only user #{login}"
  # g.save

  m = Membership.new
  u = User.find_by_login(login)
  g = Group.find_by_name(login)
  m.user_id = u.id
  m.group_id = g.id
  m.save

end
