# Base controller for the application.
#
# Provides authentication helpers and current user resolution
# for different user roles (Administrador, Aluno, Professor).
class ApplicationController < ActionController::Base

  # Exposes authentication helper methods to the views.
  helper_method :current_user,
                :logged_in?,
                :current_aluno,
                :current_professor,
                :current_administrador

  private

  # Returns the currently logged-in user, regardless of role.
  #
  # The user is resolved based on session data, which must include
  # both the user ID and the user type.
  #
  # @return [Administrador, Aluno, Professor, nil]
  #   The authenticated user instance or nil if no user is logged in.
  #
  # Side effects:
  # - Reads from the session
  # - Queries the database
  def current_user
    return nil unless session[:user_id] && session[:user_type]

    @current_user ||= begin
      user_class = session[:user_type].constantize
      user_class.find_by(id: session[:user_id])
    end
  end

  # Checks whether a user is currently logged in.
  #
  # @return [Boolean]
  #   true if a user is authenticated, false otherwise.
  #
  # Side effects:
  # - Calls +current_user+
  def logged_in?
    current_user.present?
  end

  # Enforces authentication for protected pages.
  #
  # If the user is not logged in, redirects to the login page.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  # - Sets a flash alert message
  def require_login
    unless logged_in?
      flash[:alert] = 'Você precisa fazer login para acessar esta página'
      redirect_to login_path
    end
  end

  # Returns the current administrator, if logged in as one.
  #
  # @return [Administrador, nil]
  #
  # Side effects:
  # - Calls +current_user+
  def current_administrador
    return nil unless logged_in? && current_user.is_a?(Administrador)
    current_user
  end

  # Restricts access to administrator-only actions.
  #
  # Redirects to the admin login page if the user is not an administrator.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  # - Sets a flash alert message
  def authenticate_administrador!
    unless current_administrador
      flash[:alert] = 'Acesso restrito a administradores'
      redirect_to admin_login_path
    end
  end

  # Returns the current student, if logged in as one.
  #
  # @return [Aluno, nil]
  #
  # Side effects:
  # - Calls +current_user+
  def current_aluno
    return nil unless logged_in? && current_user.is_a?(Aluno)
    current_user
  end

  # Restricts access to student-only actions.
  #
  # Redirects to the login page if the user is not a student.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  # - Sets a flash alert message
  def authenticate_aluno!
    unless current_aluno
      flash[:alert] = 'Acesso restrito a alunos'
      redirect_to login_path
    end
  end

  # Returns the current professor, if logged in as one.
  #
  # @return [Professor, nil]
  #
  # Side effects:
  # - Calls +current_user+
  def current_professor
    return nil unless logged_in? && current_user.is_a?(Professor)
    current_user
  end

  # Restricts access to professor-only actions.
  #
  # Redirects to the login page if the user is not a professor.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  # - Sets a flash alert message
  def authenticate_professor!
    unless current_professor
      flash[:alert] = 'Acesso restrito a professores'
      redirect_to login_path
    end
  end
end
