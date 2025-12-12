module Admin
  class FormulariosController < Admin::ApplicationController
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
      @respostas_count = @formulario.respostas.select(:aluno_id).distinct.count
      @total_students = @formulario.turma.alunos.count
    end
    
    # POST /admin/formularios
    def create
      @formulario = current_administrador.formularios.new(formulario_params)
      @templates = current_administrador.templates
      @turmas = Turma.all
      
      if @formulario.save
        # Assign form to all students in the class
        assign_form_to_students(@formulario)
        
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário criado e enviado aos alunos com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    # GET /admin/formularios/1/results
    def results
      # Get all answers for this form (anonymous)
      @respostas = @formulario.respostas
                             .includes(:pergunta)
                             .order('perguntas.id')
      
      # Group answers by question for reporting
      @answers_by_question = @respostas.group_by(&:pergunta)
      
      # Statistics
      @total_responses = @respostas.select(:aluno_id).distinct.count
      @total_students = @formulario.turma.alunos.count
      @response_rate = @total_students > 0 ? (@total_responses.to_f / @total_students * 100).round(1) : 0
    end
    
    # DELETE /admin/formularios/1
    def destroy
      @formulario.destroy
      redirect_to admin_formularios_url, 
                  notice: 'Formulário excluído com sucesso.'
    end
    
    private
    
    def set_formulario
      @formulario = current_administrador.formularios.find(params[:id])
    end
    
    def formulario_params
      params.require(:formulario).permit(:template_id, :turma_id)
    end
    
    def assign_form_to_students(formulario)
      # Add form to all students in the class
      formulario.turma.alunos.each do |aluno|
        aluno.formularios_respostas << formulario
      end
    end
  end
end