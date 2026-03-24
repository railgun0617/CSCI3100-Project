Rails.application.routes.draw do
  get "equipment/index"
  get "equipment/show"
  get "equipment/new"
  get "equipment/edit"
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
  resources :bookings, only: [:index, :new, :create] do
    member do
      patch :approve
      patch :reject
    end
  end

  get 'staff/dashboard', to: 'staff#dashboard'
  get 'login', to: 'login#index'
end
