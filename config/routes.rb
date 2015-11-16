Rails.application.routes.draw do

  devise_for :users
  resources :events

  get 'events_users/invite/:id' => 'events_users#invite', :as => :invite_events_users

  root "events#index"
end
