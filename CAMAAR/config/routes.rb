Rails.application.routes.draw do
  get "pages/login"
  get "pages/dashboard"
  # Root path
  root 'templates#index'
  
  # Template resources
  resources :templates do
    resources :perguntas, only: [:new, :create]
  end
  
  # Other resources (already generated)
  resources :alunos
  resources :professors
  resources :administradors
  resources :disciplinas
  resources :turmas
  resources :formularios
  resources :perguntas
  
  # Simple routes for now
  get 'login', to: 'pages#login'
  get 'dashboard', to: 'pages#dashboard'
end