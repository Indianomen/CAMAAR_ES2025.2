# Namespace for student-related controllers.
module Student

  # Controller responsible for rendering the student dashboard.
  #
  # Provides summary information related to the currently authenticated
  # student, including pending and answered forms.
  class DashboardController < ApplicationController

    # Ensures that only authenticated students can access the dashboard.
    before_action :authenticate_aluno!

    # Displays the student dashboard page.
    #
    # Calculates statistics related to the student's forms, such as
    # pending forms, answered forms and total available forms.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def index
      @formularios_pendentes_count = current_aluno.formularios_pendentes.count

      formularios_respondidos = Formulario.joins(perguntas: :respostas)
                                          .where(respostas: { aluno_id: current_aluno.id })
                                          .distinct
      @formularios_respondidos_count = formularios_respondidos.count

      @total_formularios = current_aluno.formularios.count
    end
  end
end
