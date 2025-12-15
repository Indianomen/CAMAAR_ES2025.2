module Admin
  class DashboardController < Admin::BaseController
    def index
      @total_formularios = current_administrador.formularios.count
      @total_templates = current_administrador.templates.count
    end
  end
end
