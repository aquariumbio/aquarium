# IN GENERAL WE ARE FOLLOWING THE SPIRIT OF RAILS CONVENTIONS WITH THE FOLLOWING CHANGES
#   - WE ARE STICKING WITH GET AND POST METHODS (SO WE DO NOT HAVE TO PROCESS A HIDDEN "_METHOD" ATTRIBUTE)
#   - WE ARE USING EXPLICIT URLS BASED ON THE CONTROLLER#ACTION
#
# HERE IS A SUMMARY TABLE FOR REFERENCE
#
#   Rails Method + Path         API Method + path       Controller#Action  # NOTES
#   GET        /item            GET   /item             item#index         # retrieve all items
#   GET        /item/new        ---                     ---                # NOT USED - form is built on the front-end
#   POST       /item            POST  /item/create      item#create        # create item
#   GET        /item/:id        GET   /item/:id         item#show          # retrieve item
#   GET        /item/:id/edit   ---                     ---                # NOT USED - form is built on the front-end
#   PATCH/PUT  /item/:id        POST  /item/:id/update  item#update        # update item
#   DELETE     /item/:id        POST  /item/:id/delete  item#delete        # delete item
#
# IN ALL CASES WHERE A TOKEN IS PASSED, THE :TOKEN IS PASSED AS A PARAMETER SO IT IS NOT IN THE URL


Rails.application.routes.draw do

  # TOKENS
  post 'api/v3/token/create',                    to: 'api/v3/token#create'
  post 'api/v3/token/delete',                    to: 'api/v3/token#delete'
  get  'api/v3/token/get_user',                  to: 'api/v3/token#get_user'

  # PERMISSIONS
  get  'api/v3/permissions',                     to: 'api/v3/permissions#index'

  # USER PERMISSIONS
  get  'api/v3/users/permissions',               to: 'api/v3/users#permissions'
  post 'api/v3/users/permissions/update',        to: 'api/v3/users#permissions_update'

  get 'api/v3/sample_types/create',             to: 'api/v3/sample_types#create'
  get 'api/v3/sample_types/:id/update',         to: 'api/v3/sample_types#update'
  get 'api/v3/sample_types/:id/delete',         to: 'api/v3/sample_types#delete'

  # SAMPLE TYPES
  get  'api/v3/sample_types',                    to: 'api/v3/sample_types#index'
  post 'api/v3/sample_types/create',             to: 'api/v3/sample_types#create'
  get  'api/v3/sample_types/:id',                to: 'api/v3/sample_types#show'
  post 'api/v3/sample_types/:id/update',         to: 'api/v3/sample_types#update'
  post 'api/v3/sample_types/:id/delete',         to: 'api/v3/sample_types#delete'

  # OBJECT TYPES
  # get  'api/v3/object_types',                    to: 'api/v3/object_types#index'
  # post 'api/v3/object_types/create',             to: 'api/v3/object_types#create'
  # get  'api/v3/object_types/:id',                to: 'api/v3/object_types#show'
  # post 'api/v3/object_types/:id/update',         to: 'api/v3/object_types#update'
  # post 'api/v3/object_types/:id/delete',         to: 'api/v3/object_types#delete'


end

