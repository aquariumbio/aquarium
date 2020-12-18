# In general we are following the spirit of rails conventions with the following changes
#   - We are sticking with get and post methods (so we do not have to process a hidden "_method" attribute)
#   - We are using explicit urls based on the controller#action
#
# Here is a summary table for reference
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
# In all cases where a token is passed, the :token is passed as a parameter so it is not in the url


Rails.application.routes.draw do

  # Tokens
  post 'api/v3/token/create',                     to: 'api/v3/token#create'
  post 'api/v3/token/delete',                     to: 'api/v3/token#delete'
  get  'api/v3/token/get_user',                   to: 'api/v3/token#get_user'

  # Permissions
  get  'api/v3/permissions',                      to: 'api/v3/permissions#index'

  # User permissions (for possible "permissions" hamburger menu - currently unused)
  get  'api/v3/users/permissions',                to: 'api/v3/users#permissions'
  post 'api/v3/users/permissions/update',         to: 'api/v3/users#update_permission'

  # Users
  get  'api/v3/users',                             to: 'api/v3/users#index'
  post 'api/v3/users/create',                      to: 'api/v3/users#create'
  get  'api/v3/users/:id',                         to: 'api/v3/users#show'
  get  'api/v3/users/:id/show_info',               to: 'api/v3/users#show_info'
  post 'api/v3/users/:id/update_info',             to: 'api/v3/users#update_info'
  post 'api/v3/users/:id/update_permissions',      to: 'api/v3/users#update_permissions'
  post 'api/v3/users/:id/agreements/:agreement',   to: 'api/v3/users#agreements', constraints: { agreement: /lab|aquarium/ }
  post 'api/v3/users/:id/preferences/:preference', to: 'api/v3/users#preferences', constraints: { preference: /new_samples_private|lab_name/ }

  # Groups
  get  'api/v3/groups',                           to: 'api/v3/groups#index'
  post 'api/v3/groups/create',                    to: 'api/v3/groups#create'
  get  'api/v3/groups/:id',                       to: 'api/v3/groups#show'
  post 'api/v3/groups/:id/update',                to: 'api/v3/groups#update'
  post 'api/v3/groups/:id/delete',                to: 'api/v3/groups#delete'

  # Announcements
  get  'api/v3/announcements',                     to: 'api/v3/announcements#index'
  post 'api/v3/announcements/create',              to: 'api/v3/announcements#create'
  get  'api/v3/announcements/:id',                 to: 'api/v3/announcements#show'
  post 'api/v3/announcements/:id/update',          to: 'api/v3/announcements#update'
  post 'api/v3/announcements/:id/delete',          to: 'api/v3/announcements#delete'

  # Budgets

  # Invoices

  # Parameters
  get  'api/v3/parameters',                        to: 'api/v3/parameters#index'
  post 'api/v3/parameters/create',                 to: 'api/v3/parameters#create'
  get  'api/v3/parameters/:id',                    to: 'api/v3/parameters#show'
  post 'api/v3/parameters/:id/update',             to: 'api/v3/parameters#update'
  post 'api/v3/parameters/:id/delete',             to: 'api/v3/parameters#delete'

  # Sample Types
  get  'api/v3/sample_types',                     to: 'api/v3/sample_types#index'
  post 'api/v3/sample_types/create',              to: 'api/v3/sample_types#create'
  get  'api/v3/sample_types/:id',                 to: 'api/v3/sample_types#show'
  post 'api/v3/sample_types/:id/update',          to: 'api/v3/sample_types#update'
  post 'api/v3/sample_types/:id/delete',          to: 'api/v3/sample_types#delete'

  # Object Types
  get  'api/v3/object_types',                     to: 'api/v3/object_types#index'
  post 'api/v3/object_types/create',              to: 'api/v3/object_types#create'
  get  'api/v3/object_types/handler/:handler',    to: 'api/v3/object_types#show_handler'
  get  'api/v3/object_types/:id',                 to: 'api/v3/object_types#show'
  post 'api/v3/object_types/:id/update',          to: 'api/v3/object_types#update'
  post 'api/v3/object_types/:id/delete',          to: 'api/v3/object_types#delete'

  # Location Wizards

end

