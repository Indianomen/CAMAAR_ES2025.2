# Controller responsible for managing administrators.
#
# Provides CRUD actions for creating, viewing, updating and deleting
# administrator records.
class AdministradorsController < ApplicationController

  # Loads the administrator for actions that require an existing record.
  before_action :set_administrador, only: %i[ show edit update destroy ]

  # Lists all administrators.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns instance variables used by the view
  def index
    @administradors = Administrador.all
  end

  # Displays a specific administrator.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def show
  end

  # Displays the administrator creation form.
  #
  # @return [void]
  #
  # Side effects:
  # - Instantiates a new Administrador object
  def new
    @administrador = Administrador.new
  end

  # Displays the administrator editing form.
  #
  # @return [void]
  #
  # Side effects:
  # - Assigns instance variables used by the view
  def edit
  end

  # Creates a new administrator.
  #
  # @return [void]
  #
  # Side effects:
  # - Attempts to persist a new record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def create
    @administrador = Administrador.new(administrador_params)

    respond_to do |format|
      if @administrador.save
        format.html { redirect_to @administrador, notice: "Administrador was successfully created." }
        format.json { render :show, status: :created, location: @administrador }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @administrador.errors, status: :unprocessable_entity }
      end
    end
  end

  # Updates an existing administrator.
  #
  # @return [void]
  #
  # Side effects:
  # - Updates a record in the database
  # - Redirects or renders views depending on success or failure
  # - Responds to HTML and JSON formats
  def update
    respond_to do |format|
      if @administrador.update(administrador_params)
        format.html { redirect_to @administrador, notice: "Administrador was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @administrador }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @administrador.errors, status: :unprocessable_entity }
      end
    end
  end

  # Deletes an administrator.
  #
  # @return [void]
  #
  # Side effects:
  # - Removes a record from the database
  # - Redirects the HTTP request
  # - Responds to HTML and JSON formats
  def destroy
    @administrador.destroy!

    respond_to do |format|
      format.html { redirect_to administradors_path, notice: "Administrador was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Loads the administrator based on the request parameters.
  #
  # @return [void]
  #
  # Side effects:
  # - Queries the database
  # - Assigns an instance variable
  def set_administrador
    @administrador = Administrador.find(params.expect(:id))
  end

  # Defines permitted parameters for administrator creation and update.
  #
  # @return [ActionController::Parameters] permitted parameters
  #
  # Side effects:
  # - Filters request parameters
  def administrador_params
    params.expect(
      administrador: [
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
