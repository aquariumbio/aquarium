Bioturk::Application.routes.draw do

  resources :primers
  match "primers/:id", to: 'primers#stock', via: [:post]
  match "primers/:id/delete_stock/:item_id", to: 'primers#delete_stock', via: [:get,:post]

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
  
  match '/signup', to: 'users#new'

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :jobs, only: [:index, :destroy, :show]
  resources :logs, only: [:index, :show]

  match '/item', to: 'items#update'

end
