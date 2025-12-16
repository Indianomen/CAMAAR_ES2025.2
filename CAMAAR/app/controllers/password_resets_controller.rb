# Controller responsible for handling password reset flow.
#
# Allows students and professors to request a password reset and
# update their credentials using a secure token.
class PasswordResetsController < ApplicationController

  # Loads the user based on the signed reset token for edit and update actions.
  before_action :find_user_by_token, only: [:edit, :update]

  # Displays the password reset request form.
  #
  # @return [void]
  #
  # Side effects:
  # - Renders the password reset request view
  def new
  end

  # Creates a password reset request.
  #
  # Finds the user by email and sends password reset instructions
  # via email if the user exists.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Enqueues an email delivery job
  # - Redirects or renders views
  def create
    email = params[:email]

    @user = Aluno.find_by(email: email) || Professor.find_by(email: email)

    if @user
      PasswordResetMailer.reset_password(@user).deliver_later

      redirect_to login_path,
                  notice: 'Instruções de reset de senha foram enviadas para seu email.'
    else
      flash.now[:alert] = 'Email não encontrado'
      render :new, status: :unprocessable_entity
    end
  end

  # Displays the password reset form.
  #
  # @return [void]
  #
  # Side effects:
  # - Renders the password reset form view
  def edit
  end

  # Updates the user's password.
  #
  # Validates and saves the new password. If the user was not previously
  # registered, marks them as registered.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates user credentials in the database
  # - Updates the registration status
  # - Redirects or renders views
  def update
    if @user.update(user_params)
      @user.update_column(:registered, true) unless @user.registered?

      redirect_to login_path,
                  notice: 'Senha atualizada com sucesso! Faça login com sua nova senha.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Finds a user based on a signed password reset token.
  #
  # The token is validated for expiration and purpose.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Redirects if the token is invalid or expired
  def find_user_by_token
    token = params[:id]

    @user = Aluno.find_signed(token, purpose: :password_reset) ||
            Professor.find_signed(token, purpose: :password_reset)

    if @user.nil?
      redirect_to login_path,
                  alert: 'O link de reset de senha é inválido ou expirou. Solicite um novo.'
    end
  end

  # Defines permitted parameters for updating the user password.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
