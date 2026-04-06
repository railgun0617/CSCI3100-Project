Rails.application.routes.draw do
  get "manage_resources/index"
  get "resources/index"
  devise_for :users, controllers: { registrations: "registrations" }
  namespace :admin do
    get "users/new"
    get "users/create"
    resources :users, only: [:new, :create]
  end
  # get "equipment/index"
  # get "equipment/show"
  # get "equipment/new"
  # get "equipment/edit"
  get "staff/dashboard"
  get "bookings/index"
  get "bookings/new"
  get "venues/index"
  get "venues/show"
  get "venues/new"
  get "venues/edit"
  ## get "home/index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  ## get "up" => "rails/health#show", as: :rails_health_check


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"

  resources :venues
  resources :equipment
  resources :bookings, only: [:index, :new, :create, :destroy] do
    member do
      patch :approve
      patch :reject
    end
  end

  post 'create_booking', to: 'bookings#create_booking', as: 'create_booking'
  get 'staff/dashboard', to: 'staff#dashboard'
  get 'resources', to: 'resources#index'
  get 'manage_resources', to: 'manage_resources#index'  # or use department/manage
  get '/favicon.ico', to: redirect('/assets/favicon.ico')

end
