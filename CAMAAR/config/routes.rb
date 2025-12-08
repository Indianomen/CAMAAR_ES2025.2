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
  resources :professor
  resources :administradors
  resources :disciplinas
  resources :turmas
  resources :formularios
  resources :perguntas
  
  # Simple routes for now
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'dashboard', to: 'pages#dashboard'
  
  # Password Reset (Esqueci minha senha)
  resources :password_resets, only: [:new, :create, :edit, :update]
  
  # Password Setup (from email invite)
  get 'password_setups/:token/edit', to: 'password_setups#edit', as: :edit_password_setup
  patch 'password_setups/:token', to: 'password_setups#update', as: :password_setup

  namespace :admin do
    root to: "dashboard#index"

    resources :administradors, only: [:index, :show, :create, :update, :destroy]
    resources :alunos
    resources :professors
    resources :disciplinas
    resources :templates
    resources :formularios
    resources :turmas

    get "avaliacoes", to: "pages#avaliacoes"
    get "gerenciamento", to: "pages#gerenciamento"

    # Sessões de Administrador
    get  "login",  to: "sessions#new"
    post "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    # Página principal do painel
    get "importacoes", to: "pages#importacoes"
    get "resultados",  to: "pages#resultados"
  end
end

