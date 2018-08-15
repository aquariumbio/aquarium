# coding: utf-8

Bioturk::Application.routes.draw do

  resources :timings, only: %i[update create]

  get '/uploads/:type/:id/:key', to: 'uploads#show'

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
  get '/operations/:id/retry',                   to: 'operations#retry'
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

  post '/invoices/note',                         to: 'invoices#note'
  post '/invoices/credit',                       to: 'invoices#credit'
  get '/invoices/year/:year',                    to: 'invoices#index'
  post '/invoices/change_budget',                to: 'invoices#change_budget'
  get '/invoices/change_status/:id/:status',     to: 'invoices#change_status'
  resources :invoices

  get '/accounts',                               to: 'accounts#index'
  get '/accounts/deposit',                       to: 'accounts#deposit'
  get '/accounts/:uid',                          to: 'accounts#index'
  get '/accounts/:uid/:month/:year',             to: 'accounts#index'

  get 'containers_list',                         to: 'object_types#containers'
  get 'collection_containers_list',              to: 'object_types#collection_containers'
  get 'sample_types_list',                       to: 'object_types#sample_types'
  get 'sample_list/:id',                         to: 'object_types#samples'
  get 'sample_list',                             to: 'object_types#samples'

  resources :posts, only: %i[index create]

  get 'wizards/contents/:id',               to: 'wizards#contents'
  resources :wizards

  get 'item_list', to: 'items#item_list'
  get 'upload', to: 'jobs#upload'

  get '/groups/names'

  resources :groups

  post '/collections/:id/assign_sample', to: 'collections#assign_sample'

  resources :collections do # Not sure this is used anymore
    member do
      get 'associate'
      get 'dissociate'
      get 'newitem'
    end
  end

  resources :samples
  resources :sample_types

  get '/spreadsheet', to: 'samples#spreadsheet'
  get '/process_spreadsheet', to: 'samples#process_spreadsheet'

  get 'technician/:job_id', to: 'technician#index'

  get 'krill/debug/:id', to: 'krill#debug'
  get 'krill/start'
  get 'krill/continue'
  get 'krill/log'
  get 'krill/state'
  post 'krill/next'
  get 'krill/error'
  get 'krill/inventory'
  get 'krill/abort'
  get 'krill/jobs'
  post 'krill/upload'
  get 'krill/uploads'
  post 'krill/attach'

  get 'jobs/index'
  get 'jobs/summary'
  get 'jobs/report'

  get 'joblist', to: 'jobs#joblist'

  get '/items/store/:id',      to: 'items#store'
  get '/items/make/:sid/:oid', to: 'items#make'
  get '/items/move/:id',       to: 'items#move'
  get '/items/history/:id',    to: 'items#history'
  resources :items

  resources :object_types do
    resources :items do
      collection do
        get 'update'
      end
    end
  end

  root to: 'static_pages#home'

  get '/',            to: 'static_pages#home'
  get '/template',    to: 'static_pages#template'
  get '/graph',       to: 'static_pages#graph'
  get '/test',        to: 'static_pages#test'

  get '/signin',     to: 'sessions#new'
  get '/signout',    to: 'sessions#destroy', via: :delete

  get '/dismiss',      to: 'static_pages#dismiss'

  get '/static_pages/direct_purchase', to: 'static_pages#direct_purchase'

  get '/search', to: 'search#search'

  get '/delete_inventory', to: 'object_types#delete_inventory'

  get '/signup', to: 'users#new'
  get '/password', to: 'users#password'

  get '/users/active',        to: 'users#active'
  get 'users/current',        to: 'users#current'
  put 'users/password',       to: 'users#update_password'
  get 'users/stats/:id',      to: 'users#stats'

  resources :users do
    get 'change_password'
  end

  resources :sessions, only: %i[new create destroy]
  resources :jobs, only: %i[index destroy show]
  resources :logs, only: %i[index show]

  get '/logout', to: 'sessions#destroy'
  get '/item', to: 'items#update'

end
