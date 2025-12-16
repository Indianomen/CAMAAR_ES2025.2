# Namespace for administrative area controllers.
module Admin

  # Controller responsible for rendering the administrative dashboard.
  #
  # Provides summary information related to the currently authenticated
  # administrator, such as total counts of associated records.
  class DashboardController < Admin::BaseController

    # Displays the admin dashboard page.
    #
    # Retrieves summary statistics related to the current administrator,
    # including the total number of forms and templates.
    #
    # @return [void]
    #
    # Side effects:
    # - Assigns instance variables used by the view
    # - Reads associated records from the database
    def index
      @total_formularios = current_administrador.formularios.count
      @total_templates = current_administrador.templates.count
    end
  end
end
