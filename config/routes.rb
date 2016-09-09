Bioturk::Application.routes.draw do

  get '/plans/:pid/select/:oid',                 to: 'plans#select'
  get '/plans/start/:id',                        to: 'plans#start'
  post '/plans/replan',                          to: 'plans#replan'
  post '/plans/plan',                            to: 'plans#plan'  
  resources :plans

  post '/operations/batch',                      to: 'operations#batch'
  get '/operations/jobs',                        to: 'operations#jobs'
  resources :operations

  get '/operation_types/:id/random/:num',        to: 'operation_types#random'
  resources :operation_types do
    collection do 
      get 'default'
      post 'code'
      post 'test'
    end
  end

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
  get '/browser/search/:query(/:user_id)',       to: 'browser#search' 
  get '/browser/collections/:sample_id',         to: 'browser#collections'
  get '/browser/delete_item/:item_id',           to: 'browser#delete_item'  
  get '/browser/restore_item/:item_id',          to: 'browser#restore_item'  

  resources :parameters

  get '/budgets/add/:bid/:uid/:quota',           to: 'budgets#add_user'
  get '/budgets/remove/:bid/:uid',               to: 'budgets#remove_user'  
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

  get "/items/make/:sid/:oid", to: "items#make"
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

  match '/',        to: 'static_pages#home'

  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/status',  to: 'static_pages#status'
  match '/analytics',  to: 'static_pages#analytics'
  match '/jobchart', to: 'static_pages#jobchart'
  match '/location', to: 'static_pages#location'

  match '/yeast_qc', to: 'static_pages#yeast_qc'

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

  get 'users/current',        to: 'users#current'
  get 'users/billing/:id',    to: 'users#billing' 
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
