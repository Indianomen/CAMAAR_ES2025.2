# Controller responsible for handling initial password setup.
#
# Allows students and professors to define their password for the first time
# using a secure, signed token.
class PasswordSetupsController < ApplicationController

  # Skips CSRF verification for the update action to allow token-based access.
  skip_before_action :verify_authenticity_token, only: [:update], raise: false

  # Loads the user based on the signed setup token.
  before_action :find_user_by_token, only: [:edit, :update]

  # Prevents access if the user account is already active.
  before_action :check_user_already_active, only: [:edit]

  # Displays the password setup form.
  #
  # @return [void]
  #
  # Side effects:
  # - Renders the password setup view
  def edit
  end

  # Updates the user's password and activates the account.
  #
  # Marks the user as registered and automatically logs them in
  # after a successful password setup.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates user credentials in the database
  # - Updates the registration status
  # - Writes to the session
  # - Redirects or renders views
  def update
    if @user.update(user_params)
      @user.update_column(:registered, true)

      session[:user_id]   = @user.id
      session[:user_type] = @user.class.name

      redirect_to dashboard_path,
                  notice: 'Senha definida com sucesso! Bem-vindo ao CAMAAR.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Finds a user based on a signed password setup token.
  #
  # Validates the token for expiration and purpose.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Redirects if the token is invalid or expired
  def find_user_by_token
    token = params[:token]

    @user = Aluno.find_signed(token, purpose: :password_setup) ||
            Professor.find_signed(token, purpose: :password_setup)

    if @user.nil?
      redirect_to login_path,
                  alert: 'O link de configuração de senha é inválido ou expirou. Solicite um novo.'
    end
  end

  # Checks whether the user account is already active.
  #
  # Prevents already registered users from accessing the setup flow.
  #
  # @return [void]
  #
  # Side effects:
  # - Redirects the HTTP request
  def check_user_already_active
    if @user&.registered?
      redirect_to login_path,
                  alert: 'Sua conta já está ativa. Por favor, faça login.'
    end
  end

  # Defines permitted parameters for password setup.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
