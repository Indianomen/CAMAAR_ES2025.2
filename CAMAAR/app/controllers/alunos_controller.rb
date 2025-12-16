# Controller responsible for managing students (Alunos).
#
# Provides CRUD actions for listing, creating, viewing, updating
# and deleting student records. Access is restricted to authenticated users.
class AlunosController < ApplicationController

  # Ensures the user is authenticated before accessing any action.
  before_action :require_login

  # Loads the student for actions that require an existing record.
  before_action :set_aluno, only: %i[ show edit update destroy ]

  # Lists all students.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns instance variables used by the view
  def index
    @alunos = Aluno.all
  end

  # Displays a specific student.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def show
  end

  # Displays the student creation form.
  #
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Aluno object
  def new
    @aluno = Aluno.new
  end

  # Displays the student editing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def edit
  end

  # Creates a new student.
  #
  # @return [void]
  #
  # Side effects:
  # - Attempts to persist a new record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def create
    @aluno = Aluno.new(aluno_params)

    respond_to do |format|
      if @aluno.save
        format.html { redirect_to @aluno, notice: "Aluno was successfully created." }
        format.json { render :show, status: :created, location: @aluno }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing student.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def update
    respond_to do |format|
      if @aluno.update(aluno_params)
        format.html { redirect_to @aluno, notice: "Aluno was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @aluno }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes a student.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes a record from the database
  # - Redirects the HTTP request
  # - Responds to HTML and JSON formats
  def destroy
    @aluno.destroy!

    respond_to do |format|
      format.html { redirect_to alunos_path, notice: "Aluno was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Loads the student based on the request parameters.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns an instance variable
  def set_aluno
    @aluno = Aluno.find(params.expect(:id))
  end

  # Defines permitted parameters for student creation and update.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def aluno_params
    params.expect(
      aluno: [
        :nome,
        :curso,
        :matricula,
        :departamento,
        :formacao,
        :usuario,
        :email,
        :ocupacao,
        :registered,
        :password_digest
      ]
    )
  end
end
