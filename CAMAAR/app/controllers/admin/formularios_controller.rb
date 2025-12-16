require 'csv'

# Namespace for administrative area controllers.
module Admin

  # Controller responsible for managing forms (formularios) in the admin area.
  #
  # Provides actions for creating, viewing, editing, deleting, sending,
  # exporting and analyzing results of forms associated with the
  # currently authenticated administrator.
  class FormulariosController < ApplicationController

    # Sets the layout used by admin controllers.
    layout "admin"

    # Ensures that only authenticated administrators can access the actions.
    before_action :authenticate_administrador!

    # Loads the form for actions that require an existing record.
    before_action :set_formulario,
                  only: [:show, :edit, :update, :destroy, :results, :export_csv]

    # Lists all forms belonging to the current administrator.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def index
      @formularios = current_administrador.formularios
                                          .includes(:template, :turma)
                                          .order(created_at: :desc)
    end

    # Displays the form creation page.
    #
    # Initializes a new form and loads templates and classes (turmas)
    # available to the administrator.
    #
    # @return [void]
    #
    # Side effects:
    # - Instantiates a new Formulario object
    # - Queries the database
    # - Assigns instance variables used by the view
    def new
      @formulario = current_administrador.formularios.new
      @templates  = current_administrador.templates
      @turmas     = Turma.all.order(:semestre, :horario)
    end

    # Displays a specific form and its associated questions and answers.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def show
      @perguntas = @formulario.perguntas
      @respostas = @formulario.respostas.includes(:pergunta)
    end

    # Displays the form editing page.
    #
    # Loads templates and classes (turmas) available for editing.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def edit
      @templates = current_administrador.templates
      @turmas    = Turma.all.order(:semestre, :horario)
    end

    # Creates a new form associated with the current administrator.
    #
    # @return [void]
    #
    # Side effects:
    # - Attempts to persist a new record in the database
    # - Redirects on success
    # - Renders a view with validation errors on failure
    def create
      @formulario = current_administrador.formularios.new(formulario_params)
      @templates  = current_administrador.templates
      @turmas     = Turma.all.order(:semestre, :horario)

      if @formulario.save
        redirect_to admin_formulario_path(@formulario),
                    notice: 'Formulário criado com sucesso. Você pode enviá-lo aos alunos quando estiver pronto.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    # Sends the form to all students enrolled in the associated class.
    #
    # @return [void]
    #
    # Side effects:
    # - Updates associations between students and the form
    # - Writes data to the database
    # - Redirects the HTTP request with a flash message
    def send_to_students
      @formulario = current_administrador.formularios.find(params[:id])

      if @formulario.turma.alunos.any?
        @formulario.turma.alunos.each do |aluno|
          aluno.formularios_respostas << @formulario unless aluno.formularios_respostas.include?(@formulario)
        end

        redirect_to admin_formulario_path(@formulario),
                    notice: 'Formulário enviado para todos os alunos da turma.'
      else
        redirect_to admin_formulario_path(@formulario),
                    alert: 'Esta turma não tem alunos matriculados.'
      end
    end

    # Updates an existing form.
    #
    # @return [void]
    #
    # Side effects:
    # - Updates a record in the database
    # - Redirects on success
    # - Renders a view with validation errors on failure
    def update
      if @formulario.update(formulario_params)
        redirect_to admin_formulario_path(@formulario),
                    notice: 'Formulário atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes a form.
    #
    # @return [void]
    #
    # Side effects:
    # - Removes a record from the database
    # - Redirects the HTTP request
    def destroy
      @formulario.destroy
      redirect_to admin_formularios_url,
                  notice: 'Formulário excluído com sucesso.'
    end

    # Displays aggregated results of a form.
    #
    # Calculates response statistics and groups answers by question.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Performs calculations in memory
    # - Assigns instance variables used by the view
    def results
      @respostas = Resposta.joins(:pergunta)
                           .where(pergunta: { formulario_id: @formulario.id })
                           .includes(:pergunta)

      @answers_by_question = @respostas.group_by(&:pergunta)

      @total_responses = @respostas.select(:aluno_id).distinct.count
      @total_students  = @formulario.turma&.alunos&.count || 0
      @response_rate   = @total_students > 0 ?
        (@total_responses.to_f / @total_students * 100).round(1) : 0
    end

    # Exports form results to a CSV file.
    #
    # @return [void]
    #
    # Side effects:
    # - Generates a CSV file in memory
    # - Sends the file as an HTTP response attachment
    def export_csv
      perguntas = @formulario.perguntas.includes(:respostas)
      turma     = @formulario.turma
      template  = @formulario.template

      csv_string = CSV.generate(headers: true) do |csv|
        csv << ["Template", "Turma", "Semestre", "Pergunta", "Resposta", "Respondido em"]

        perguntas.each do |pergunta|
          pergunta.respostas.each do |resposta|
            csv << [
              template.nome,
              turma.disciplina.nome,
              turma.semestre,
              pergunta.texto,
              resposta.texto,
              I18n.l(resposta.created_at, format: :short)
            ]
          end
        end
      end

      filename = "resultados_formulario_#{@formulario.id}.csv"

      send_data csv_string,
                filename: filename,
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end

    private

    # Loads the form associated with the given request parameters.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns an instance variable
    def set_formulario
      @formulario = current_administrador.formularios.find(params[:id])
    end

    # Defines permitted parameters for form creation and update.
    #
    # @return [ActionController::Parameters] permitted parameters
    #
    # Side effects:
    # - Filters request parameters
    def formulario_params
      params.require(:formulario).permit(:template_id, :turma_id)
    end

    # Associates a form with all students of its class.
    #
    # @param formulario [Formulario] the form to be assigned
    # @return [void]
    #
    # Side effects:
    # - Updates associations in the database
    def assign_form_to_students(formulario)
      formulario.turma.alunos.each do |aluno|
        aluno.formularios_respostas << formulario
      end
    end
  end
end
