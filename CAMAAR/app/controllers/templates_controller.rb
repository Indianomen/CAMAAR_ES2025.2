class TemplatesController < ApplicationController
  layout "admin"  
  before_action :require_login, except: [:index]  # Permite acesso público ao index (root_path)
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]

  # GET /templates
  def index
    if current_user.is_a?(Administrador)
      @templates = current_user.templates.includes(:perguntas).order(created_at: :desc)
    else
      @templates = Template.includes(:perguntas).order(created_at: :desc)
    end
  end

  # GET /templates/1
  def show
    @perguntas = @template.perguntas
  end

  # GET /templates/new
  def new
    @template = Template.new
    # Add 3 empty questions for the form
    3.times { @template.perguntas.build }
  end

  # GET /templates/1/edit
  def edit
    # Add an empty question for adding more
    @template.perguntas.build
  end

  # POST /templates
  def create
    @template = Template.new(template_params)
    @template.administrador = current_user if current_user.is_a?(Administrador)

    if @template.save
      redirect_to @template, notice: 'Template criado com sucesso.'
    else
      flash.now[:alert] = "Não foi possível criar o template. Verifique os erros abaixo."
      (@template.perguntas.count...3).each { @template.perguntas.build } if @template.perguntas.count < 3
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      redirect_to @template, notice: 'Template atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy
    redirect_to templates_url, notice: 'Template excluído com sucesso.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def template_params
      params.require(:template).permit(:nome, 
        perguntas_attributes: [:id, :texto, :_destroy])
    end
    
    # Require admin for protected actions
    def require_admin
      unless current_user.is_a?(Administrador)
        redirect_to root_path, alert: 'Acesso não autorizado.'
      end
    end
end