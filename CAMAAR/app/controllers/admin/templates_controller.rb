# Namespace for administrative area controllers.
module Admin

  # Controller responsible for managing templates.
  #
  # Provides actions to create, view, update and delete templates
  # associated with the currently authenticated administrator.
  class TemplatesController < Admin::ApplicationController

    # Loads the template for actions that require an existing record.
    before_action :set_template, only: [:show, :edit, :update, :destroy]

    # Lists all templates belonging to the current administrator.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def index
      @templates = current_administrador.templates
                                         .includes(:perguntas)
                                         .order(created_at: :desc)
    end

    # Displays a specific template and its questions.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def show
      @perguntas = @template.perguntas
    end

    # Displays the template creation page.
    #
    # Initializes a new template with a default number of questions.
    #
    # @return [void]
    #
    # Side effects:
    # - Instantiates a new Template object
    # - Builds associated question objects
    # - Assigns instance variables used by the view
    def new
      @template = current_administrador.templates.new
      3.times { @template.perguntas.build }
    end

    # Displays the template editing page.
    #
    # Builds an additional question to allow insertion via the form.
    #
    # @return [void]
    #
    # Side effects:
    # - Builds an associated question object
    # - Assigns instance variables used by the view
    def edit
      @template.perguntas.build
    end

    # Creates a new template.
    #
    # @return [void]
    #
    # Side effects:
    # - Attempts to persist a new record in the database
    # - Redirects the HTTP request on success
    # - Renders the form with validation errors on failure
    def create
      @template = current_administrador.templates.new(template_params)

      if @template.save
        redirect_to admin_template_path(@template),
                    notice: 'Template criado com sucesso.'
      else
        flash.now[:alert] = "Não foi possível criar o template. Verifique os erros abaixo."
        (@template.perguntas.count...3).each { @template.perguntas.build } if @template.perguntas.count < 3
        render :new, status: :unprocessable_entity
      end
    end

    # Updates an existing template.
    #
    # @return [void]
    #
    # Side effects:
    # - Updates a record in the database
    # - Redirects the HTTP request on success
    # - Renders the form with validation errors on failure
    def update
      if @template.update(template_params)
        redirect_to admin_template_path(@template),
                    notice: 'Template atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes a template.
    #
    # @return [void]
    #
    # Side effects:
    # - Removes a record from the database
    # - Redirects the HTTP request
    def destroy
      @template.destroy
      redirect_to admin_templates_url,
                  notice: 'Template excluído com sucesso.'
    end

    private

    # Loads the template associated with the given request parameters.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns an instance variable
    def set_template
      @template = current_administrador.templates.find(params[:id])
    end

    # Defines permitted parameters for template creation and update.
    #
    # @return [ActionController::Parameters] permitted parameters
    #
    # Side effects:
    # - Filters request parameters
    def template_params
      params.require(:template).permit(
        :nome,
        perguntas_attributes: [:id, :texto, :_destroy]
      )
    end
  end
end
