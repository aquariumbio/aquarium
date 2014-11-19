def make_user name, login, password, opts={}

  options = { admin: false }. merge opts

  user = User.new(name: name, login: login, password: password, password_confirmation: password)
  user.admin = options[:admin]
  user.save 

  group = Group.new
  group.name = user.login
  group.description = "A group containing only user #{user.name}"
  group.save

  m = Membership.new
  m.group_id = group.id
  m.user_id = user.id
  m.save

  user

end
