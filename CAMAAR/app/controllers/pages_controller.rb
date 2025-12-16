# Controller responsible for handling generic application pages.
#
# Manages the home page, login page and role-based dashboard redirection.
class PagesController < ApplicationController

  # Requires authentication for all actions except the home page.
  before_action :require_login, except: [:home]

  # Handles the application home page.
  #
  # Redirects authenticated users to the dashboard and unauthenticated
  # users to the login page.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  def home
    if logged_in?
      redirect_to dashboard_path
    else
      redirect_to login_path
    end
  end

  # Displays the login page.
  #
  # @return [void]
  #
  # Side effects:
  # - Renders the login view
  def login
  end

  # Redirects the user to the appropriate dashboard based on their role.
  #
  # @return [void]
  #
  # Side effects:
  # - Inspects the current user role
  # - Redirects the HTTP request
  def dashboard
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
