module Student
  class FormulariosController < ApplicationController
    before_action :authenticate_aluno!
    before_action :set_formulario, only: [:show, :submit]
    before_action :validate_formulario_access, only: [:show, :submit]
    before_action :validate_not_already_answered, only: [:show, :submit]
    
    def index
      @formularios_pendentes = current_aluno.formularios_pendentes
                                            .includes(:template, :turma, :perguntas)
                                            .order(created_at: :desc)
    end
    
    def show
      @perguntas = @formulario.perguntas.order(:id)
    end
    
    def submit
      unless logged_in?
        flash[:alert] = "Sua sessão expirou. Por favor, faça login novamente."
        redirect_to login_path
        return
      end
      
      respostas_params = params[:respostas] || {}
      perguntas = @formulario.perguntas
      
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
      
      begin
        ActiveRecord::Base.transaction do
          perguntas.each do |pergunta|
            Resposta.create!(
              aluno: current_aluno,
              pergunta: pergunta,
              texto: respostas_params[pergunta.id.to_s].strip
            )
          end
          
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
    
    def set_formulario
      @formulario = Formulario.find_by(id: params[:id])
      
      unless @formulario
        flash[:alert] = "Formulário não encontrado."
        redirect_to student_formularios_path
      end
    end
    
    def validate_formulario_access
      return unless @formulario
      
      unless current_aluno.turmas.include?(@formulario.turma)
        flash[:alert] = "Você não tem permissão para acessar este formulário."
        redirect_to student_formularios_path
      end
    end
    
    def validate_not_already_answered
      return unless @formulario
      
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
