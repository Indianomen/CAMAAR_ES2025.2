module Admin
  class TemplatesController < ApplicationController
    before_action :set_template, only: [:show, :edit, :update, :destroy]

    # GET /admin/templates
    def index
      @templates = current_administrador.templates.includes(:perguntas).order(created_at: :desc)
    end

    # GET /admin/templates/1
    def show
      @perguntas = @template.perguntas
    end

    # GET /admin/templates/new
    def new
      @template = current_administrador.templates.new
      # Add 3 empty questions for the form
      3.times { @template.perguntas.build }
    end

    # GET /admin/templates/1/edit
    def edit
      # Add an empty question for adding more
      @template.perguntas.build
    end

    # POST /admin/templates
    def create
      @template = current_administrador.templates.new(template_params)

      if @template.save
        redirect_to admin_template_path(@template), notice: 'Template criado com sucesso.'
      else
        flash.now[:alert] = "Não foi possível criar o template. Verifique os erros abaixo."
        (@template.perguntas.count...3).each { @template.perguntas.build } if @template.perguntas.count < 3
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/templates/1
    def update
      if @template.update(template_params)
        redirect_to admin_template_path(@template), notice: 'Template atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/templates/1
    def destroy
      @template.destroy
      redirect_to admin_templates_url, notice: 'Template excluído com sucesso.'
    end

    private

    def set_template
      @template = current_administrador.templates.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:nome, 
        perguntas_attributes: [:id, :texto, :_destroy])
    end
  end
end