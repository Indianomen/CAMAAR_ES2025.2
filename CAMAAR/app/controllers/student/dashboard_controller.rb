module Student
  class DashboardController < ApplicationController
    before_action :authenticate_aluno!
    
    def index
      @formularios_pendentes_count = current_aluno.formularios_pendentes.count
      
      # Count forms that have actual responses from this student
      # A form is considered "answered" if the student has at least one Resposta for it
      formularios_respondidos = Formulario.joins(:perguntas => :respostas)
                                          .where(respostas: { aluno_id: current_aluno.id })
                                          .distinct
      @formularios_respondidos_count = formularios_respondidos.count
      
      @total_formularios = current_aluno.formularios.count
    end
  end
end