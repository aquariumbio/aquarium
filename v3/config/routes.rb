Rails.application.routes.draw do

  post 'api/v3/user/sign_in',                    to: 'api/v3/user#sign_in'
  post 'api/v3/user/sign_out',                   to: 'api/v3/user#sign_out'

  post 'api/v3/user/test_token',                 to: 'api/v3/user#test_token'

end
