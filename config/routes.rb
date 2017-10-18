Bioturk::Application.routes.draw do
 
  resources :timings, only: [ :update, :create ]

  get '/json/current',             to: 'json#current'
  post '/json/items',              to: 'json#items'
  post '/json/save',               to: 'json#save'  
  post '/json/delete',             to: 'json#delete'    
  post '/json/upload',             to: 'json#upload'    
  post '/json',                    to: 'json#index'

  post '/launcher/estimate',                     to: 'launcher#estimate'
  post '/launcher/submit',                       to: 'launcher#submit'  
  get '/launcher/plans',                         to: 'launcher#plans'  
  get '/launcher',                               to: 'launcher#index'
  get '/launcher/:id/relaunch',                  to: 'launcher#relaunch'  

  get '/plans/:pid/select/:oid',                 to: 'plans#select'
  get '/plans/start/:id',                        to: 'plans#start'
  get '/plans/costs/:id',                        to: 'plans#costs'
  get '/plans/cancel/:id/:msg',                  to: 'plans#cancel' 
  get '/plans/:id/debug',                        to: 'plans#debug'
  get '/plans/replan/:id',                       to: 'plans#replan'
  post '/plans/plan',                            to: 'plans#plan'  
  put '/plans/move',                             to: 'plans#move'
  get '/plans/folders',                          to: 'plans#folders'
  get '/plans/operation_types/:deployed_only',   to: 'plans#operation_types'
  resources :plans

  post '/operations/manager_list',               to: 'operations#manager_list'
  get '/operations/step',                        to: 'operations#step'
  post '/operations/batch',                      to: 'operations#batch'
  post '/operations/unbatch',                    to: 'operations#unbatch'  
  get '/operations/jobs',                        to: 'operations#jobs'
  get '/operations/:id/status/:status',          to: 'operations#set_status'
  resources :operations

  post '/operation_types/import',                    to: 'operation_types#import'    
  get '/operation_types/numbers/:user_id/:filter',   to: 'operation_types#numbers'    
  get '/operation_types/:id/stats',                  to: 'operation_types#stats'
  get '/operation_types/:id/random/:num',            to: 'operation_types#random'
  get '/operation_types/:id/export',                 to: 'operation_types#export'  
  get '/operation_types/export_category/:category',  to: 'operation_types#export_category'  
  get '/operation_types/:id/copy',                   to: 'operation_types#copy'  
  get '/operation_types/deployed_with_timing',       to: 'operation_types#deployed_with_timing'

  resources :operation_types do
    collection do 
      get 'default'
      post 'code'
      post 'test'
    end
  end

  resources :libraries do
    collection do 
      post 'code'
    end
  end

  resources :announcements

  get '/developer',                              to: 'developer#developer'
  post '/developer/get/',                        to: 'developer#get'  
  post '/developer/save',                        to: 'developer#save'    
  post '/developer/test',                        to: 'developer#test'      
  post '/developer/pull',                        to: 'developer#pull'        

  get '/browser',                                to: 'browser#browser'
  get '/browser/all',                            to: 'browser#all'  
  get '/browser/projects',                       to: 'browser#projects'    
  get '/browser/samples_for_tree',               to: 'browser#samples_for_tree'  
  get '/browser/samples/:id/:offset(/:user_id)', to: 'browser#samples'  
  get '/browser/sub/:id',                        to: 'browser#subsamples'
  get '/browser/annotate/:id/:note',             to: 'browser#annotate'  
  get '/browser/items/:id',                      to: 'browser#items'
  post '/browser/create_samples',                to: 'browser#create_samples'
  post '/browser/save',                          to: 'browser#save'
  post '/browser/save_data_association',         to: 'browser#save_data_association'    
  get '/browser/recent_samples/:id',             to: 'browser#recent_samples'  
  post '/browser/search',                        to: 'browser#search' 
  get '/browser/collections/:sample_id',         to: 'browser#collections'
  get '/browser/delete_item/:item_id',           to: 'browser#delete_item'  
  get '/browser/restore_item/:item_id',          to: 'browser#restore_item'  

  resources :parameters

  get '/budgets/add/:bid/:uid/:quota',           to: 'budgets#add_user'
  get '/budgets/remove/:bid/:uid',               to: 'budgets#remove_user'  
  get '/budgets/:id/spent',                      to: 'launcher#spent'
  resources :budgets

  post '/invoices/note',                         to: "invoices#note"
  post '/invoices/credit',                       to: "invoices#credit"  
  get '/invoices/year/:year',                    to: 'invoices#index'  
  post '/invoices/change_budget',                to: 'invoices#change_budget'  
  get '/invoices/change_status/:id/:status',     to: 'invoices#change_status'
  resources :invoices

  get '/accounts',                               to: 'accounts#index'  
  get '/accounts/deposit',                       to: 'accounts#deposit'
  get '/accounts/:uid',                          to: 'accounts#index'  
  get '/accounts/:uid/:month/:year',             to: 'accounts#index'      

  get '/sample_tree/samples',                    to: 'sample_tree#samples'  
  get '/sample_tree/jobs/:id',                   to: 'sample_tree#jobs'  
  get '/sample_tree/annotate/:id/:note',         to: 'sample_tree#annotate'
  get '/sample_tree/:id',                        to: 'sample_tree#show'
  
  get 'containers_list',                         to: 'object_types#containers'  
  get 'collection_containers_list',              to: 'object_types#collection_containers'    
  get 'sample_types_list',                       to: 'object_types#sample_types'
  get 'sample_list/:id',                         to: 'object_types#samples'
  get 'sample_list',                             to: 'object_types#samples'

  resources :posts, only: [ :index, :create ]
  resources :wizards

  match "api", to: "api#main"

  get "plugin/tester"
  get "plugin/show"
  get "plugin/ajax"

  get "finder/projects"
  get "finder/types"
  get "finder/samples"
  get "finder/containers"
  get "finder/items"
  get "finder/sample_info"
  get "finder/type"

  match "rich_id", to: "tasks#rich_id"
  match "item_list", to: "items#item_list"
  match "upload", to: "jobs#upload"

  match "tasks/upload", to: "tasks#upload"
  match "tasks/list/:offset", to: "tasks#list"

  resources :tasks
  resources :task_prototypes

  match "notifications", to: "tasks#notifications"
  match "notification_list", to: "tasks#notification_list"
  match "read", to: "tasks#read"

  get "metacols/draw"
  match 'viewer',        to: 'metacols#viewer'

  resources :metacols do
    get 'arguments', on: :new
    get 'narguments', on: :new
    get 'launch', on: :new
    get 'stop'
  end 

  get "/groups/names"

  resources :groups

  resources :collections do
    member do
      get 'associate'
      get 'dissociate'
      get 'newitem'
    end
  end

  resources :cart_items, only: [ :index, :new, :destroy ]
  resources :samples
  resources :sample_types

  match '/spreadsheet', to: 'samples#spreadsheet'
  match '/process_spreadsheet', to: 'samples#process_spreadsheet'

  match "interpreter/open_local_file", to: 'interpreter#open_local_file', via: [:post]

  get "interpreter/arguments"
  get "interpreter/narguments"
  get "interpreter/submit"
  get "interpreter/current"
  get "interpreter/advance"
  get "interpreter/abort"
  get "interpreter/cancel"
  get "interpreter/error"
  get "interpreter/release"
  get "interpreter/edit"
  get "interpreter/resubmit"

  get "krill/debug/:id", to: "krill#debug"
  get "krill/arguments"
  get "krill/submit"
  get "krill/start"
  get "krill/continue"
  get "krill/log"
  get "krill/ui"
  get "krill/state"
  post "krill/next"
  get "krill/error"
  get "krill/inventory"
  get "krill/abort"
  get "krill/jobs"
  post "krill/upload"
  get "krill/uploads"
  get "krill/tasks"
  post "krill/attach"

  get "stats/jobs"
  get "stats/users"
  get "stats/user_activity"
  get "stats/protocols"
  get "stats/outcomes"
  get "stats/samples"
  get "stats/objects"
  get "stats/processes"
  get "stats/empty"
  get "stats/timing"
  get "stats/user_items" 
  get "stats/protocol_version_info"
  get "jobs/index"
  get "jobs/summary"
  match "joblist", to: "jobs#joblist"

  get "protocol_tree/file"
  get "protocol_tree/recent"

  get "repo/list"
  get "repo/get"
  get "repo/pull"

  get "/items/store/:id",      to: "items#store"
  get "/items/make/:sid/:oid", to: "items#make"
  get "/items/move/:id",       to: "items#move"
  get "/items/history/:id",    to: "items#history"
  resources :items

  match "project", to: 'samples#project'

  resources :object_types do 
    resources :items do
      collection do
        get 'update'
      end
    end
  end

  root to: 'static_pages#home'

  match '/',            to: 'static_pages#home'
  match '/template',    to: 'static_pages#template'

  match '/help',       to: 'static_pages#help'
  match '/about',      to: 'static_pages#about'
  match '/signin',     to: 'sessions#new'
  match '/signout',    to: 'sessions#destroy', via: :delete
  match '/status',     to: 'static_pages#status'
  match '/analytics',  to: 'static_pages#analytics'
  match '/jobchart',   to: 'static_pages#jobchart'
  match '/location',   to: 'static_pages#location'
  get "/dismiss",      to: 'static_pages#dismiss'

  match '/yeast_qc', to: 'static_pages#yeast_qc'

  get '/static_pages/direct_purchase', to: 'static_pages#direct_purchase'

  match '/glass', to: 'sessions#glass'

  match '/search', to: 'search#search'
  
  match '/inventory_stats', to: 'static_pages#inventory_stats'
  match '/inventory_critical', to: 'static_pages#inventory_critical'
  match '/protocol_usage', to: 'static_pages#protocol_usage'
  match '/cost_report', to: 'static_pages#cost_report'  

  get '/production_interface', to: 'object_types#production_interface'
  get '/delete_inventory', to: 'object_types#delete_inventory'
  get '/copy_inventory_from_production', to: 'object_types#copy_inventory_from_production'
  get '/copy_users_from_production', to: 'users#copy_users_from_production'
  get '/copy_tasks_from_production', to: 'tasks#copy_tasks_from_production'
  get '/update_task_status', to: 'tasks#update_status'

  match '/signup', to: 'users#new'
  match '/password', to: 'users#password'

  get '/users/active',        to: 'users#active'
  get 'users/current',        to: 'users#current'
  get 'users/billing/:id',    to: 'users#billing' 
  put 'users/password',       to: 'users#update_password'
  
  resources :users do 
    get 'change_password'
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :jobs, only: [:index, :destroy, :show]
  resources :logs, only: [:index, :show]

  match '/logout', to: 'sessions#destroy'
  match '/item', to: 'items#update'

  get "oyster/ping"
  get "oyster/submit"
  get "oyster/status"
  get "oyster/log"
  get "oyster/info"
  get "oyster/items"

end
 