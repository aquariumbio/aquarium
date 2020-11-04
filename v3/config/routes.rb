Rails.application.routes.draw do

  post 'api/v3/token/create',                    to: 'api/v3/token#create'
  post 'api/v3/token/delete',                    to: 'api/v3/token#delete'
  post 'api/v3/token/get_user',                  to: 'api/v3/token#get_user'

  post 'api/v3/users/roles',                     to: 'api/v3/users#roles'
  post 'api/v3/users/set_role',                  to: 'api/v3/users#set_role'

  post 'api/v3/roles/get_roles',                 to: 'api/v3/roles#get_roles'

end
