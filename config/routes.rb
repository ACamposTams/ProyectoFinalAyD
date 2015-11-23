Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'registrations'}, :except => [:invites, :stats]
  get '/users/stats' => 'users#stats'
  get '/users/invites' => 'users#invites'
  resources :events
  resources :events_users
  resources :users

  get '/users/invites' => 'users#invites', :as => :invites_users
  get '/users/stats' => 'users#stats', :as => :stats_users
  get '/users/show' => 'users#show', :as => :show_users
  get '/search' => 'users#search', :as => :search

  get 'events_users/invite/:id' => 'events_users#invite', :as => :invite_events_users
  get 'tags/:tag', to: 'events#index', as: "tag"
  
  root "events#index"

  get '*unmatched_route', :to => 'events#index', notice: "Unmatched Route"
end