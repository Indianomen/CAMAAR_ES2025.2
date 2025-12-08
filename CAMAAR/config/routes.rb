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

