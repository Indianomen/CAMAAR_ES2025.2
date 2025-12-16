# Controller responsible for managing disciplines (Disciplinas).
#
# Provides CRUD actions to list, create, view, update and delete
# discipline records.
class DisciplinasController < ApplicationController

  # Loads the discipline for actions that require an existing record.
  before_action :set_disciplina, only: %i[ show edit update destroy ]

  # Lists all disciplines.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns instance variables used by the view
  def index
    @disciplinas = Disciplina.all
  end

  # Displays a specific discipline.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def show
  end

  # Displays the discipline creation form.
  #
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Disciplina object
  def new
    @disciplina = Disciplina.new
  end

  # Displays the discipline editing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def edit
  end

  # Creates a new discipline.
  #
  # @return [void]
  #
  # Side effects:
  # - Attempts to persist a new record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def create
    @disciplina = Disciplina.new(disciplina_params)

    respond_to do |format|
      if @disciplina.save
        format.html { redirect_to @disciplina, notice: "Disciplina was successfully created." }
        format.json { render :show, status: :created, location: @disciplina }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @disciplina.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing discipline.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def update
    respond_to do |format|
      if @disciplina.update(disciplina_params)
        format.html { redirect_to @disciplina, notice: "Disciplina was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @disciplina }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @disciplina.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes a discipline.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes a record from the database
  # - Redirects the HTTP request
  # - Responds to HTML and JSON formats
  def destroy
    @disciplina.destroy!

    respond_to do |format|
      format.html { redirect_to disciplinas_path, notice: "Disciplina was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Loads the discipline based on the request parameters.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns an instance variable
  def set_disciplina
    @disciplina = Disciplina.find(params.expect(:id))
  end

  # Defines permitted parameters for discipline creation and update.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def disciplina_params
    params.expect(disciplina: [ :codigo, :nome ])
  end
end
