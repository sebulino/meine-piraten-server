Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    get  "sign_in",  to: "users/sessions#new",     as: :new_user_session
    delete "sign_out", to: "users/sessions#destroy", as: :destroy_user_session
    get "users/auth/failure", to: "users/omniauth_callbacks#failure"
  end
  resources :tasks do
    resources :comments, only: [ :index, :create, :destroy ]
  end
  resources :entities
  get "api", to: "pages#api"
  resources :categories
  resources :admin_requests, only: [:index, :create] do
    collection do
      get :status
    end
    member do
      patch :approve
      patch :reject
      patch :demote
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "tasks#index"
end
