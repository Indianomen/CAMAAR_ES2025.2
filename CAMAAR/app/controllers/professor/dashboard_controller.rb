# Namespace for professor-related controllers.
module Professor

  # Controller responsible for rendering the professor dashboard.
  #
  # Provides a placeholder dashboard page for professors.
  class DashboardController < ApplicationController

    # Displays the professor dashboard page.
    #
    # Currently renders a plain text message indicating that
    # the dashboard is under construction.
    #
    # @return [void]
    #
    # Side effects:
    # - Sends a plain text HTTP response
    def index
      render plain: "Professor Dashboard - Under Construction"
    end
  end
end
