Bioturk::Application.routes.draw do

  get '/tree',                           to: 'tree#tree'
  get '/tree/all',                       to: 'tree#all'  
  get '/tree/projects',                  to: 'tree#projects'    
  get '/tree/samples_for_tree',          to: 'tree#samples_for_tree'  
  get '/tree/sub/:id',                   to: 'tree#subsamples'
  post '/tree/save_new',                 to: 'tree#save_new'
  post '/tree/save',                     to: 'tree#save'
  
  resources :parameters

  get '/budgets/add/:bid/:uid/:quota',      to: 'budgets#add_user'
  get '/budgets/remove/:bid/:uid',          to: 'budgets#remove_user'  
  resources :budgets

  get '/invoices/year/:year',              to: 'invoices#index'    
  resources :invoices

  get '/accounts',                         to: 'accounts#index'  
  get '/accounts/deposit',                 to: 'accounts#deposit'
  get '/accounts/:uid',                    to: 'accounts#index'  
  get '/accounts/:uid/:month/:year',       to: 'accounts#index'      

  get '/sample_tree/samples',              to: 'sample_tree#samples'  
  get '/sample_tree/jobs/:id',             to: 'sample_tree#jobs'  
  get '/sample_tree/annotate/:id/:note',   to: 'sample_tree#annotate'
  get '/sample_tree/:id',                  to: 'sample_tree#show'

  resources :workflows
  post '/workflows/:id/save',               to: 'workflows#save'
  get '/workflows/:id/new_operation',       to: 'workflows#new_operation'
  get '/workflows/:id/drop_operation/:oid', to: 'workflows#drop_operation'
  get '/workflows/:id/identify',            to: 'workflows#identify'

  get '/operations/make',                   to: 'operations#make' 

  resources :operations
  get '/operations/:id/new_part',           to: 'operations#new_part'
  get '/operations/:id/new_exception',      to: 'operations#new_exception'
  get '/operations/:id/new_exception_part', to: 'operations#new_exception_part'
  get '/operations/:id/drop_part',          to: 'operations#drop_part'
  get '/operations/:id/rename',             to: 'operations#rename'
  get '/operations/:id/rename_part',        to: 'operations#rename_part'  
  
  get 'containers_list',             to: 'operations#containers'  
  get 'collection_containers_list',  to: 'operations#collection_containers'    
  get 'sample_types_list',           to: 'operations#sample_types'
  get 'sample_list/:id',             to: 'operations#samples'
  get 'sample_list',                 to: 'operations#samples'

  get 'workflow_processes/kill/:id',    to: 'workflow_processes#kill'
  get 'workflow_processes/active',      to: 'workflow_processes#active'
  get 'workflow_processes/recent',      to: 'workflow_processes#recent'  
  get 'workflow_processes/rerun',       to: 'workflow_processes#rerun'
  get 'workflow_processes/step',        to: 'workflow_processes#step'

  resources :workflow_processes, only: [ :index, :show, :new, :create ]

  resources :workflow_threads, only: [ :create, :index, :destroy ]

  resources :posts, only: [ :index, :create ]
  resources :wizards

  post 'folders', to: 'folders#index'
  resources :folders, only: [ :index ]

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
