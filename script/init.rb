# frozen_string_literal: true

def make_user(name, login, password, opts = {})
  options = { admin: false }. merge opts

  user = User.create!(name: name, login: login, password: password, password_confirmation: password)
  user.make_admin if options[:admin]
  user.create_user_group
  user.save

  user
end
