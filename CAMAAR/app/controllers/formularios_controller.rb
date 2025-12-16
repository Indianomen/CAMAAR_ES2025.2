# Controller responsible for managing forms (Formulários) in the admin area.
#
# Provides actions to create, view, update, delete and analyze results
# of forms created by administrators.
class FormulariosController < ApplicationController

  # Uses the admin layout for all views rendered by this controller.
  layout "admin"

  # Restricts access to authenticated administrators only.
  before_action :authenticate_administrador!

  # Loads the form for actions that require an existing record.
  before_action :set_formulario, only: [:show, :edit, :update, :destroy, :results]

  # Lists all forms created by the current administrator.
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
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Formulario object
  # - Queries templates and classes (turmas)
  def new
    @formulario = current_administrador.formularios.new
    @templates  = current_administrador.templates
    @turmas     = Turma.all.order(:semestre, :horario)
  end

  # Displays a specific form.
  #
  # @return [void]
  #
  # Side effects:
  # - Loads associated questions
  def show
    @perguntas = @formulario.perguntas
  end

  # Displays the form editing page.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries templates and classes (turmas)
  def edit
    @templates = current_administrador.templates
    @turmas    = Turma.all.order(:semestre, :horario)
  end

  # Creates a new form.
  #
  # @return [void]
  #
  # Side effects:
  # - Persists a new record in the database
  # - Redirects or renders views depending on success or failure
  def create
    @formulario = current_administrador.formularios.new(formulario_params)
    @templates  = current_administrador.templates
    @turmas     = Turma.all.order(:semestre, :horario)

    if @formulario.save
      redirect_to admin_formulario_path(@formulario),
                  notice: 'Formulário criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Updates an existing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
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

  # Displays aggregated results for a form.
  #
  # Calculates response statistics and groups answers by question.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Performs calculations
  # - Assigns instance variables used by the view
  def results
    @respostas = Resposta.joins(:pergunta)
                         .where(pergunta: { formulario_id: @formulario.id })

    @answers_by_question = @respostas.group_by(&:pergunta)

    @total_responses = @respostas.count
    @total_students  = @formulario.turma&.alunos&.count || 0
    @response_rate   = @total_students > 0 ?
      (@total_responses.to_f / @total_students * 100).round(1) : 0
  end

  private

  # Loads the form based on the request parameters.
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
end
