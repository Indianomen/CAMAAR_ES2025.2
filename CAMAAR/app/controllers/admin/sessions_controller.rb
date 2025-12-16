# Namespace for administrative area controllers.
module Admin

  # Controller responsible for administrator authentication sessions.
  #
  # Manages login and logout actions for administrators, handling
  # session creation and destruction.
  class SessionsController < Admin::BaseController

    # Sets the layout used by the authentication pages.
    layout "admin"

    # Skips authentication check for login-related actions.
    skip_before_action :authenticate_administrador!, only: [:new, :create]

    # Displays the administrator login page.
    #
    # @return [void]
    #
    # Side effects:
    # - Renders the login view
    def new
    end

    # Creates a new administrator session.
    #
    # Authenticates the administrator using the provided credentials
    # and stores the administrator ID in the session upon success.
    #
    # @return [void]
    #
    # Side effects:
    # - Reads request parameters
    # - Writes data to the session
    # - Redirects the HTTP request on success
    # - Renders the login page with an alert on failure
    def create
      administrador = Administrador.find_by(usuario: params[:usuario])

      if administrador&.authenticate(params[:password])
        session[:administrador_id] = administrador.id
        redirect_to admin_root_path
      else
        flash[:alert] = "Usuário ou senha inválidos"
        render :new
      end
    end

    # Destroys the current administrator session.
    #
    # Logs out the administrator by removing the session data.
    #
    # @return [void]
    #
    # Side effects:
    # - Deletes data from the session
    # - Redirects the HTTP request to the login page
    def destroy
      session.delete(:administrador_id)
      redirect_to admin_login_path
    end
  end
end
