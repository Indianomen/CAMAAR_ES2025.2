class TemplatesController < ApplicationController
  before_action :set_template, only: %i[:show, :edit, :update, :destroy]
  before_action :require_admin, except: %i[:index, :show]

  # GET /templates or /templates.json
  def index
    if current_user.is_a?(Administrador)
      @templates = current_user.templates.includes(:perguntas)
    else
      @templates = Template.includes(:perguntas).all
    end
  end

  # GET /templates/1 or /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
    # Define 3 perguntas iniciais vazias
    3.times { @template.perguntas.build }
  end

  # GET /templates/1/edit
  def edit
    # Adiciona perguntas vazias
    @template.perguntas.build if @template.perguntas.empty?
  end

  # POST /templates or /templates.json
  def create
    @template = Template.new(template_params)
    @template.administrador = current_user if current_user.is_a?(Administrador)

    if @template.save
      redirect_to @template, notice: "Template criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /templates/1 or /templates/1.json
  def update
    if @template.update(template_params)
      redirect_to @template, notice: "Template atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /templates/1 or /templates/1.json
  def destroy
    @template.destroy
    redirect_to templates_url, notice: "Template excluído com sucesso."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def template_params
      params.require(:template).permit(:nome, 
        perguntas_attributes: [:id, :texto, :_destroy])
    end
    private
  
    def require_admin
      unless current_user.is_a?(Administrador)
        redirect_to root_path, alert: "Acesso não autorizado."
      end
    end
end 
