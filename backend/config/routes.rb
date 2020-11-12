Rails.application.routes.draw do

  post 'api/v3/token/create',                    to: 'api/v3/token#create'
  post 'api/v3/token/delete',                    to: 'api/v3/token#delete'
  post 'api/v3/token/get_user',                  to: 'api/v3/token#get_user'

  post 'api/v3/users/permissions',                     to: 'api/v3/users#permissions'
  post 'api/v3/users/set_permission',                  to: 'api/v3/users#set_permission'

  post 'api/v3/permissions/get_permissions',                 to: 'api/v3/permissions#get_permissions'

end
