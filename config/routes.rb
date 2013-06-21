Bioturk::Application.routes.draw do

  get "liason/select"
  get "liason/update"

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

  match '/item', to: 'items#update'

end
