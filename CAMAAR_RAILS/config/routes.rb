Rails.application.routes.draw do
  resources :admins
  resources :professors
  resources :students
  resources :classesses
  resources :courses
  resources :questions
  resources :forms
  resources :templates

  get "up" => "rails/health#show", as: :rails_health_check

  root 'dashboard#index'
  
  # Authentication routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Resources
  resources :users
  resources :templates do
    post 'create_forms', on: :member  # For creating forms from templates
  end
  resources :forms do
    resources :responses, only: [:create, :update]
    post 'submit', on: :member
  end
  resources :questions
  resources :responses
end