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
    # Redirect based on user type
    if current_user.is_a?(Aluno)
      redirect_to student_dashboard_path
    elsif current_user.is_a?(Professor)
      redirect_to professor_dashboard_path
    elsif current_user.is_a?(Administrador)
      redirect_to admin_path
    else
      redirect_to login_path, alert: 'Por favor, faça login para continuar.'
    end
  end
end