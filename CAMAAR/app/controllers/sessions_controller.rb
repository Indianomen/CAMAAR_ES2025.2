# Controller responsible for managing user sessions (authentication).
#
# Handles login and logout logic for Aluno and Professor users.
class SessionsController < ApplicationController

  # Prevents access to login pages if the user is already authenticated.
  before_action :redirect_if_logged_in, only: [:new, :create]

  # Displays the login form.
  #
  # @return [void]
  def new
  end

  # Authenticates a user and creates a session.
  #
  # The method attempts to authenticate first as an Aluno, and if not found,
  # as a Professor. Only registered users with valid credentials are allowed.
  #
  # @return [void]
  #
  # Side effects:
  # - Sets session variables (:user_id, :user_type)
  # - Redirects on success
  # - Renders login form with error on failure
  def create
    email = params[:email]
    password = params[:password]

    user = Aluno.find_by(email: email)
    user_type = 'Aluno'

    if user.nil?
      user = Professor.find_by(email: email)
      user_type = 'Professor'
    end

    if user && user.registered? && user.authenticate(password)
      session[:user_id] = user.id
      session[:user_type] = user_type

      redirect_to dashboard_path, notice: 'Login realizado com sucesso!'
    else
      @error_message = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end

  # Destroys the current session (logout).
  #
  # @return [void]
  #
  # Side effects:
  # - Clears session variables
  # - Redirects to login page
  def destroy
    session.delete(:user_id)
    session.delete(:user_type)

    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end

  private

  # Redirects the user if already logged in.
  #
  # Validates the stored session data and ensures the user still exists.
  # If the user is valid, redirects to the dashboard.
  # If not, clears the session.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects authenticated users
  # - Clears invalid session data
  def redirect_if_logged_in
    if session[:user_id] && session[:user_type]
      user_class = session[:user_type].constantize
      user = user_class.find_by(id: session[:user_id])

      if user
        redirect_to dashboard_path, notice: 'Você já está logado!'
      else
        session.delete(:user_id)
        session.delete(:user_type)
      end
    end
  end
end
