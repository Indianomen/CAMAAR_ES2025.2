module Student
  class FormulariosController < ApplicationController
    before_action :authenticate_aluno!
    before_action :set_formulario, only: [:show, :submit]
    before_action :validate_formulario_access, only: [:show, :submit]
    before_action :validate_not_already_answered, only: [:show, :submit]
    
    # GET /aluno/formularios
    # Lista todos os formulários pendentes do aluno
    def index
      @formularios_pendentes = current_aluno.formularios_pendentes
                                            .includes(:template, :turma, :perguntas)
                                            .order(created_at: :desc)
    end
    
    # GET /aluno/formularios/:id
    # Exibe o formulário para preenchimento
    def show
      @perguntas = @formulario.perguntas.order(:id)
    end
    
    # POST /aluno/formularios/:id/submit
    # Submete as respostas do formulário
    def submit
      # Validação de sessão
      unless logged_in?
        flash[:alert] = "Sua sessão expirou. Por favor, faça login novamente."
        redirect_to login_path
        return
      end
      
      # Validação de respostas obrigatórias
      respostas_params = params[:respostas] || {}
      perguntas = @formulario.perguntas
      
      # Verificar se todas as perguntas foram respondidas
      missing_answers = []
      perguntas.each do |pergunta|
        resposta_texto = respostas_params[pergunta.id.to_s]
        if resposta_texto.blank?
          missing_answers << pergunta.id
        end
      end
      
      if missing_answers.any?
        flash.now[:alert] = "Por favor, responda todas as perguntas obrigatórias."
        @perguntas = perguntas.order(:id)
        render :show, status: :unprocessable_entity
        return
      end
      
      # Persistência em transação
      begin
        ActiveRecord::Base.transaction do
          # Criar respostas para cada pergunta
          perguntas.each do |pergunta|
            Resposta.create!(
              aluno: current_aluno,
              pergunta: pergunta,
              texto: respostas_params[pergunta.id.to_s].strip
            )
          end
          
          # The form is already in alunos_formularios (added when admin sent it)
        end
        
        flash[:notice] = "Respostas enviadas com sucesso! Obrigado por participar da avaliação."
        redirect_to student_formularios_path
        
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:alert] = "Erro ao salvar respostas: #{e.message}"
        @perguntas = perguntas.order(:id)
        render :show, status: :unprocessable_entity
      end
    end
    
    private
    
    # Carrega o formulário pelo ID
    def set_formulario
      @formulario = Formulario.find_by(id: params[:id])
      
      unless @formulario
        flash[:alert] = "Formulário não encontrado."
        redirect_to student_formularios_path
      end
    end
    
    # Validação 1: Verifica se o formulário pertence a uma turma do aluno
    def validate_formulario_access
      return unless @formulario
      
      unless current_aluno.turmas.include?(@formulario.turma)
        flash[:alert] = "Você não tem permissão para acessar este formulário."
        redirect_to student_formularios_path
      end
    end
    
    # Validação 2: Verifica se o aluno ainda não respondeu o formulário
    def validate_not_already_answered
      return unless @formulario
      
      # Check if student has actual responses for this form
      # A form is considered "answered" if there are Resposta records for it
      has_responses = Resposta.joins(:pergunta)
                              .where(pergunta: { formulario_id: @formulario.id }, aluno_id: current_aluno.id)
                              .exists?
      
      if has_responses
        flash[:alert] = "Você já respondeu este formulário."
        redirect_to student_formularios_path
      end
    end
  end
end
