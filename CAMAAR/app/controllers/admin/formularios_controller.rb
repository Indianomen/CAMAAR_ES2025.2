require 'csv'

module Admin
  class FormulariosController < ApplicationController
    layout "admin"
    before_action :authenticate_administrador!
    before_action :set_formulario, only: [:show, :edit, :update, :destroy, :results, :export_csv]
    
    def index
      @formularios = current_administrador.formularios
                                          .includes(:template, :turma)
                                          .order(created_at: :desc)
    end
    
    def new
      @formulario = current_administrador.formularios.new
      @templates  = current_administrador.templates
      @turmas     = Turma.all.order(:semestre, :horario)
    end
    
    def show
      @perguntas = @formulario.perguntas
      @respostas = @formulario.respostas.includes(:pergunta)
    end
    
    def edit
      @templates = current_administrador.templates
      @turmas    = Turma.all.order(:semestre, :horario)
    end
    
    def create
      @formulario = current_administrador.formularios.new(formulario_params)
      @templates  = current_administrador.templates
      @turmas     = Turma.all.order(:semestre, :horario)
      
      if @formulario.save
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário criado com sucesso. Você pode enviá-lo aos alunos quando estiver pronto.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def send_to_students
      @formulario = current_administrador.formularios.find(params[:id])
      
      if @formulario.turma.alunos.any?
        @formulario.turma.alunos.each do |aluno|
          aluno.formularios_respostas << @formulario unless aluno.formularios_respostas.include?(@formulario)
        end
        
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário enviado para todos os alunos da turma.'
      else
        redirect_to admin_formulario_path(@formulario), 
                    alert: 'Esta turma não tem alunos matriculados.'
      end
    end
    
    def update
      if @formulario.update(formulario_params)
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @formulario.destroy
      redirect_to admin_formularios_url, 
                  notice: 'Formulário excluído com sucesso.'
    end
    
    def results
      @respostas = Resposta.joins(:pergunta)
                           .where(pergunta: { formulario_id: @formulario.id })
                           .includes(:pergunta)
      
      @answers_by_question = @respostas.group_by(&:pergunta)
      
      @total_responses = @respostas.select(:aluno_id).distinct.count
      @total_students = @formulario.turma&.alunos&.count || 0
      @response_rate = @total_students > 0 ? 
        (@total_responses.to_f / @total_students * 100).round(1) : 0

    end

    def export_csv
      perguntas = @formulario.perguntas.includes(:respostas)
      turma     = @formulario.turma
      template  = @formulario.template

      csv_string = CSV.generate(headers: true) do |csv|
        csv << ["Template", "Turma", "Semestre", "Pergunta", "Resposta", "Respondido em"]

        perguntas.each do |pergunta|
          pergunta.respostas.each do |resposta|
            csv << [
              template.nome,
              turma.disciplina.nome,
              turma.semestre,
              pergunta.texto,
              resposta.texto,
              I18n.l(resposta.created_at, format: :short)
            ]
          end
        end
      end

      filename = "resultados_formulario_#{@formulario.id}.csv"

      send_data csv_string,
                filename: filename,
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end
    
    private
    
    def set_formulario
      @formulario = current_administrador.formularios.find(params[:id])
    end
    
    def formulario_params
      params.require(:formulario).permit(:template_id, :turma_id)
    end

    def assign_form_to_students(formulario)
      formulario.turma.alunos.each do |aluno|
        aluno.formularios_respostas << formulario
      end
    end
  end
end
