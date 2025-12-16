# Controller responsible for managing professors.
#
# Provides CRUD actions to list, create, view, update and delete
# professor records.
class ProfessorsController < ApplicationController

  # Loads the professor for actions that require an existing record.
  before_action :set_professor, only: %i[ show edit update destroy ]

  # Lists all professors.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns instance variables used by the view
  def index
    @professors = Professor.all
  end

  # Displays a specific professor.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def show
  end

  # Displays the professor creation form.
  #
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Professor object
  def new
    @professor = Professor.new
  end

  # Displays the professor editing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def edit
  end

  # Creates a new professor.
  #
  # @return [void]
  #
  # Side effects:
  # - Persists a new record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def create
    @professor = Professor.new(professor_params)

    respond_to do |format|
      if @professor.save
        format.html { redirect_to @professor, notice: "Professor was successfully created." }
        format.json { render :show, status: :created, location: @professor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @professor.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing professor.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def update
    respond_to do |format|
      if @professor.update(professor_params)
        format.html { redirect_to @professor, notice: "Professor was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @professor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @professor.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes a professor.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes a record from the database
  # - Redirects the HTTP request
  # - Responds to HTML and JSON formats
  def destroy
    @professor.destroy!

    respond_to do |format|
      format.html { redirect_to professors_path, notice: "Professor was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Loads the professor based on the request parameters.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns an instance variable
  def set_professor
    @professor = Professor.find(params.expect(:id))
  end

  # Defines permitted parameters for professor creation and update.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def professor_params
    params.expect(
      professor: [
        :nome,
        :departamento,
        :formacao,
        :usuario,
        :email,
        :ocupacao,
        :password_digest
      ]
    )
  end
end
