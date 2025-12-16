# Namespace for administrative area controllers.
#
# All controllers inside this module inherit shared authentication
# and layout behavior specific to administrators.
module Admin

  # Base controller for all admin area controllers.
  #
  # This controller enforces administrator authentication,
  # sets the admin layout and provides helper methods related
  # to the currently logged administrator.
  class ApplicationController < ::ApplicationController

    # Sets the layout used by all admin controllers.
    layout "admin"

    # Ensures that only authenticated administrators can access admin pages.
    before_action :authenticate_administrador!

    # Exposes authentication helper methods to views.
    helper_method :current_administrador, :administrador_signed_in?

    private

    # Returns the currently authenticated administrator.
    #
    # Retrieves the administrator record based on the
    # administrator ID stored in the session.
    #
    # @return [Administrador, nil] the current administrator if logged in,
    #   or nil if no administrator is authenticated
    #
    # Side effects:
    # - Reads data from the session
    # - Memoizes the administrator in an instance variable
    def current_administrador
      @current_administrador ||= Administrador.find_by(
        id: session[:administrador_id]
      )
    end

    # Checks whether an administrator is currently signed in.
    #
    # @return [Boolean] true if an administrator is authenticated,
    #   false otherwise
    #
    # Side effects:
    # - None
    def administrador_signed_in?
      current_administrador.present?
    end

    # Authenticates access to admin area.
    #
    # Verifies if an administrator is logged in. If not,
    # redirects the user to the admin login page with an alert message.
    #
    # @return [void]
    #
    # Side effects:
    # - Sets a flash alert message
    # - Redirects the HTTP request to the admin login page
    def authenticate_administrador!
      unless administrador_signed_in?
        flash[:alert] = "Acesso restrito a administradores"
        redirect_to admin_login_path
      end
    end
  end
end
