# Controller responsible for managing questions (Perguntas).
#
# Provides CRUD actions to list, create, view, update and delete
# question records.
class PerguntaController < ApplicationController

  # Loads the question for actions that require an existing record.
  before_action :set_perguntum, only: %i[ show edit update destroy ]

  # Lists all questions.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns instance variables used by the view
  def index
    @pergunta = Perguntum.all
  end

  # Displays a specific question.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def show
  end

  # Displays the question creation form.
  #
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Perguntum object
  def new
    @perguntum = Perguntum.new
  end

  # Displays the question editing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def edit
  end

  # Creates a new question.
  #
  # @return [void]
  #
  # Side effects:
  # - Persists a new record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def create
    @perguntum = Perguntum.new(perguntum_params)

    respond_to do |format|
      if @perguntum.save
        format.html { redirect_to @perguntum, notice: "Perguntum was successfully created." }
        format.json { render :show, status: :created, location: @perguntum }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @perguntum.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing question.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def update
    respond_to do |format|
      if @perguntum.update(perguntum_params)
        format.html { redirect_to @perguntum, notice: "Perguntum was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @perguntum }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @perguntum.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes a question.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes a record from the database
  # - Redirects the HTTP request
  # - Responds to HTML and JSON formats
  def destroy
    @perguntum.destroy!

    respond_to do |format|
      format.html { redirect_to pergunta_path, notice: "Perguntum was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Loads the question based on the request parameters.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns an instance variable
  def set_perguntum
    @perguntum = Perguntum.find(params.expect(:id))
  end

  # Defines permitted parameters for question creation and update.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def perguntum_params
    params.expect(perguntum: [ :template_id, :formulario_id, :texto, :resposta ])
  end
end
