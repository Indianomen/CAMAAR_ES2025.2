# Namespace for administrative area controllers.
module Admin

  # Base controller for admin-specific controllers.
  #
  # This controller serves as a common superclass for all
  # admin controllers, ensuring that the admin layout is used
  # and that administrator authentication is enforced.
  #
  # It does not introduce new public methods, but applies
  # shared behavior through inheritance and filters.
  class BaseController < Admin::ApplicationController

    # Sets the layout used by admin controllers.
    layout "admin"

    # Ensures that only authenticated administrators can access
    # actions that inherit from this controller.
    before_action :authenticate_administrador!
  end
end
