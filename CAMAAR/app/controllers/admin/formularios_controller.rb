
# app/controllers/admin/formularios_controller.rb
require 'csv'

module Admin
  class FormulariosController < ApplicationController
    layout "admin"
    before_action :authenticate_administrador!
    before_action :set_formulario, only: [:show, :edit, :update, :destroy, :results, :export_csv]
    
    # GET /admin/formularios
    def index
      @formularios = current_administrador.formularios
                                          .includes(:template, :turma)
                                          .order(created_at: :desc)
    end
    
    # GET /admin/formularios/new
    def new
      @formulario = current_administrador.formularios.new
      @templates  = current_administrador.templates
      @turmas     = Turma.all.order(:semestre, :horario)
    end
    
    # GET /admin/formularios/:id
    def show
      @perguntas = @formulario.perguntas
      @respostas = @formulario.respostas.includes(:pergunta)
    end
    
    # GET /admin/formularios/:id/edit
    def edit
      @templates = current_administrador.templates
      @turmas    = Turma.all.order(:semestre, :horario)
    end
    
    # POST /admin/formularios
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

    # POST /admin/formularios/:id/send_to_students
    def send_to_students
      @formulario = current_administrador.formularios.find(params[:id])
      
      if @formulario.turma.alunos.any?
        @formulario.turma.alunos.each do |aluno|
          # Adiciona o formulário aos pendentes do aluno (evita duplicar)
          aluno.formularios_respostas << @formulario unless aluno.formularios_respostas.include?(@formulario)
        end
        
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário enviado para todos os alunos da turma.'
      else
        redirect_to admin_formulario_path(@formulario), 
                    alert: 'Esta turma não tem alunos matriculados.'
      end
    end
    
    # PATCH/PUT /admin/formularios/:id
    def update
      if @formulario.update(formulario_params)
        redirect_to admin_formulario_path(@formulario), 
                    notice: 'Formulário atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    # DELETE /admin/formularios/:id
    def destroy
      @formulario.destroy
      redirect_to admin_formularios_url, 
                  notice: 'Formulário excluído com sucesso.'
    end
    
    # GET /admin/formularios/:id/results
    def results
      @respostas = Resposta.joins(:pergunta)
                           .where(pergunta: { formulario_id: @formulario.id })
                           .includes(:pergunta)
      
      @answers_by_question = @respostas.group_by(&:pergunta)
      
      # Estatísticas
      @total_responses = @respostas.count
      @total_students  = @formulario.turma&.alunos&.count || 0
      @response_rate   = @total_students > 0 ? 
                           (@total_responses.to_f / @total_students * 100).round(1) : 0

      # Renderiza normalmente HTML; a exportação acontece via export_csv
    end

    # GET /admin/formularios/:id/export_csv
    # Gera e envia o CSV para download sem trocar de página
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

    # Caso volte a usar envio automático pós-criação, mantenha este helper
    def assign_form_to_students(formulario)
      formulario.turma.alunos.each do |aluno|
        aluno.formularios_respostas << formulario
      end
    end
  end
end
