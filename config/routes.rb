Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'registrations'}
  resources :events
  resources :events_users

  get 'events_users/invite/:id' => 'events_users#invite', :as => :invite_events_users
  get 'tags/:tag', to: 'events#index', as: "tag"
  
  root "events#index"
end