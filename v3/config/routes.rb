Rails.application.routes.draw do

  post 'api/v3/user/sign_in',                    to: 'api/v3/user#sign_in'
  post 'api/v3/user/sign_out',                   to: 'api/v3/user#sign_out'

  post 'api/v3/user/validate_token',             to: 'api/v3/user#validate_token'

  post 'api/v3/users/roles',                     to: 'api/v3/users#roles'
  post 'api/v3/users/set_role',                  to: 'api/v3/users#set_role'

  post 'api/v3/roles/get_roles',                 to: 'api/v3/roles#get_roles'

end
