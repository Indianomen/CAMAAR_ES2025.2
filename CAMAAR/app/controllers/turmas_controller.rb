# Controller responsible for managing Turma resources.
#
# Provides full CRUD operations and supports both HTML and JSON responses.
class TurmasController < ApplicationController

  # Sets the turma instance for actions that operate on a specific record.
  before_action :set_turma, only: %i[ show edit update destroy ]

  # Lists all turmas.
  #
  # @return [void]
  def index
    @turmas = Turma.all
  end

  # Displays a single turma.
  #
  # @return [void]
  def show
  end

  # Initializes a new turma instance.
  #
  # @return [void]
  def new
    @turma = Turma.new
  end

  # Displays the edit form for an existing turma.
  #
  # @return [void]
  def edit
  end

  # Creates a new turma.
  #
  # Responds with HTML or JSON depending on the request format.
  #
  # @return [void]
  #
  # Side effects:
  # - Persists a new Turma record on success
  # - Redirects or renders errors on failure
  def create
    @turma = Turma.new(turma_params)

    respond_to do |format|
      if @turma.save
        format.html { redirect_to @turma, notice: "Turma was successfully created." }
        format.json { render :show, status: :created, location: @turma }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing turma.
  #
  # Responds with HTML or JSON depending on the request format.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates the Turma record on success
  # - Redirects or renders errors on failure
  def update
    respond_to do |format|
      if @turma.update(turma_params)
        format.html { redirect_to @turma, notice: "Turma was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @turma }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes an existing turma.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes the Turma record from the database
  # - Redirects to the index page
  def destroy
    @turma.destroy!

    respond_to do |format|
      format.html { redirect_to turmas_path, notice: "Turma was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Finds and sets the turma based on the request parameters.
  #
  # @return [void]
  def set_turma
    @turma = Turma.find(params.expect(:id))
  end

  # Strong parameters for turma creation and update.
  #
  # @return [ActionController::Parameters]
  def turma_params
    params.expect(
      turma: [
        :professor_id,
        :disciplina_id,
        :formulario_id,
        :semestre,
        :horario
      ]
    )
  end

  # Returns detailed information about a turma in JSON format.
  #
  # This action is intended for API or AJAX usage.
  #
  # @return [void]
  #
  # JSON response includes:
  # - Disciplina name and code
  # - Professor name
  # - Semester and schedule
  # - Number of enrolled students
  def details
    @turma = Turma.find(params[:id])

    respond_to do |format|
      format.json do
        render json: {
          disciplina_nome: @turma.disciplina.nome,
          disciplina_codigo: @turma.disciplina.codigo,
          professor_nome: @turma.professor.nome,
          semestre: @turma.semestre,
          horario: @turma.horario,
          alunos_count: @turma.alunos.count
        }
      end
    end
  end
end
