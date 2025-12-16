# Namespace for student-related controllers.
module Student

  # Controller responsible for managing student access to forms.
  #
  # Allows students to view pending forms and submit their answers,
  # enforcing authentication and access validation rules.
  class FormulariosController < ApplicationController

    # Ensures that only authenticated students can access the actions.
    before_action :authenticate_aluno!

    # Loads the form for actions that require an existing record.
    before_action :set_formulario, only: [:show, :submit]

    # Validates whether the student has access to the form.
    before_action :validate_formulario_access, only: [:show, :submit]

    # Prevents access to forms that have already been answered.
    before_action :validate_not_already_answered, only: [:show, :submit]

    # Lists all pending forms for the current student.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def index
      @formularios_pendentes = current_aluno.formularios_pendentes
                                            .includes(:template, :turma, :perguntas)
                                            .order(created_at: :desc)
    end

    # Displays a specific form and its questions.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns instance variables used by the view
    def show
      @perguntas = @formulario.perguntas.order(:id)
    end

    # Submits the student's answers for a form.
    #
    # Validates the session state, checks for missing answers and
    # persists responses within a database transaction.
    #
    # @return [void]
    #
    # Side effects:
    # - Reads request parameters
    # - Creates response records in the database
    # - Writes flash messages
    # - Redirects or renders views based on outcome
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

    # Loads the form based on the request parameters.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Assigns an instance variable
    # - Redirects the request if the form is not found
    def set_formulario
      @formulario = Formulario.find_by(id: params[:id])

      unless @formulario
        flash[:alert] = "Formulário não encontrado."
        redirect_to student_formularios_path
      end
    end

    # Validates whether the current student is allowed to access the form.
    #
    # @return [void]
    #
    # Side effects:
    # - Redirects the HTTP request when access is denied
    # - Writes a flash alert message
    def validate_formulario_access
      return unless @formulario

      unless current_aluno.turmas.include?(@formulario.turma)
        flash[:alert] = "Você não tem permissão para acessar este formulário."
        redirect_to student_formularios_path
      end
    end

    # Prevents students from accessing forms that have already been answered.
    #
    # @return [void]
    #
    # Side effects:
    # - Queries the database
    # - Redirects the HTTP request when the form has already been answered
    # - Writes a flash alert message
    def validate_not_already_answered
      return unless @formulario

      has_responses = Resposta.joins(:pergunta)
                              .where(pergunta: { formulario_id: @formulario.id },
                                     aluno_id: current_aluno.id)
                              .exists?

      if has_responses
        flash[:alert] = "Você já respondeu este formulário."
        redirect_to student_formularios_path
      end
    end
  end
end
