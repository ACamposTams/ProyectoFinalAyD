Rails.application.routes.draw do

  devise_for :users
  resources :events

  get 'events/invite/:id' => 'events#invite', :as => :invite_event

  root "events#index"
end
