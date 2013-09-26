Bioturk::Application.routes.draw do

  resources :primers
  match "primers/:id", to: 'primers#stock', via: [:post]
  match "primers/:id/delete_stock/:item_id", to: 'primers#delete_stock', via: [:get,:post]
  match "interpreter/open_local_file", to: 'interpreter#open_local_file', via: [:post]

  get "interpreter/arguments"
  get "interpreter/submit"
  get "interpreter/current"
  get "interpreter/advance"
  get "interpreter/abort"
  get "interpreter/error"

  get "jobs/index"

  get "liaison/info"
  get "liaison/take"
  get "liaison/release"
  get "liaison/produce"

  get "protocol_tree/home"
  get "protocol_tree/subtree"
  get "protocol_tree/raw"
  get "protocol_tree/pretty"
  get "protocol_tree/parse"

  get "protocol_tree/file"
  get "protocol_tree/recent"

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
  match '/jobchart', to: 'static_pages#jobchart'

  get '/production_interface', to: 'object_types#production_interface'
  get '/delete_inventory', to: 'object_types#delete_inventory'
  get '/copy_inventory_from_production', to: 'object_types#copy_inventory_from_production'

  match '/signup', to: 'users#new'

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :jobs, only: [:index, :destroy, :show]
  resources :logs, only: [:index, :show]

  match '/item', to: 'items#update'

  get "oyster/ping"
  get "oyster/submit"
  get "oyster/status"
  get "oyster/log"
  get "oyster/info"
  get "oyster/items"

end
