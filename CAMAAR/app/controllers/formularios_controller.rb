class FormulariosController < ApplicationController
  layout "admin"
  before_action :authenticate_administrador!
  before_action :set_formulario, only: [:show, :edit, :update, :destroy, :results]
  
  # GET /admin/formularios
  def index
    @formularios = current_administrador.formularios
                                        .includes(:template, :turma)
                                        .order(created_at: :desc)
  end
  
  # GET /admin/formularios/new
  def new
    @formulario = current_administrador.formularios.new
    @templates = current_administrador.templates
    @turmas = Turma.all.order(:semestre, :horario)
  end
  
  # GET /admin/formularios/1
  def show
    @perguntas = @formulario.perguntas
  end
  
  # GET /admin/formularios/1/edit
  def edit
    @templates = current_administrador.templates
    @turmas = Turma.all.order(:semestre, :horario)
  end
  
  # POST /admin/formularios
  def create
    @formulario = current_administrador.formularios.new(formulario_params)
    @templates = current_administrador.templates
    @turmas = Turma.all.order(:semestre, :horario)
    
    if @formulario.save
      redirect_to admin_formulario_path(@formulario), 
                  notice: 'Formulário criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /admin/formularios/1
  def update
    if @formulario.update(formulario_params)
      redirect_to admin_formulario_path(@formulario), 
                  notice: 'Formulário atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /admin/formularios/1
  def destroy
    @formulario.destroy
    redirect_to admin_formularios_url, 
                notice: 'Formulário excluído com sucesso.'
  end
  
  # GET /admin/formularios/1/results
  def results
    # Get answers through the association
    @respostas = Resposta.joins(:pergunta)
                        .where(perguntas: { formulario_id: @formulario.id })
    
    # Or using the association if you have it set up:
    # @respostas = @formulario.respostas
    
    @answers_by_question = @respostas.group_by(&:pergunta)
    
    # Calculate statistics
    @total_responses = @respostas.count
    @total_students = @formulario.turma&.alunos&.count || 0
    @response_rate = @total_students > 0 ? 
      (@total_responses.to_f / @total_students * 100).round(1) : 0
  end
  
  private
  
  def set_formulario
    @formulario = current_administrador.formularios.find(params[:id])
  end
  
  def formulario_params
    params.require(:formulario).permit(:template_id, :turma_id)
  end
end