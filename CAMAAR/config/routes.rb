Rails.application.routes.draw do
  get "pages/login"
  get "pages/dashboard"

  # Root path
  root 'sessions#new'

  resources :alunos
  resources :professor
  resources :administradors
  resources :disciplinas
  resources :turmas
  resources :perguntas

  # Sessões
  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'dashboard', to: 'pages#dashboard'

  # Student namespace for student-specific routes
  namespace :student do
    get 'dashboard', to: 'dashboard#index'
    root to: 'dashboard#index'
    
    resources :formularios, only: [:index, :show] do
      member do
        post :submit
      end
    end
  end

  # Password Reset
  resources :password_resets, only: [:new, :create, :edit, :update]

  # Password Setup (via invite)
  get   'password_setups/:token/edit', to: 'password_setups#edit',   as: :edit_password_setup
  patch 'password_setups/:token',      to: 'password_setups#update', as: :password_setup

  namespace :admin do
    root to: "dashboard#index"

    resources :administradors, only: [:index, :show, :create, :update, :destroy]
    resources :alunos
    resources :professors
    resources :disciplinas
    resources :formularios do
      member do
        post :send_to_students
        get :results
        get :export_csv
      end
    end
    resources :templates do
      resources :perguntas, only: [:new, :create]
    end
    resources :turmas

  
    get 'formularios/:id/results', to: 'formularios#results', as: 'results_formulario'

    get "avaliacoes",    to: "pages#avaliacoes"
    get "gerenciamento", to: "pages#gerenciamento"

    get    "login",  to: "sessions#new"
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    post "importacoes", to: "importacoes#create"

    get "resultados", to: "pages#resultados"
  end
end
