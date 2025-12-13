class PagesController < ApplicationController
  # Requer login para acessar qualquer página, exceto home
  before_action :require_login, except: [:home]
  
  def home
    # Redireciona baseado no estado de autenticação
    if logged_in?
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end
  
  def login
  end
  
  def dashboard
  end
end